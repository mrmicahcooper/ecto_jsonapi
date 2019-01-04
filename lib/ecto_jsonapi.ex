defmodule EctoJsonapi do
  def to_json(schemas) when is_list(schemas) do
    %{
      data: Enum.map(schemas, &resource_object/1),
      included: Enum.reduce(schemas, [], &included/2) |> Enum.uniq()
    }
  end

  def to_json(schema) do
    %{
      data: resource_object(schema),
      included: included(schema, [])
    }
  end

  def resource_object(schema) do
    %{
      type: type(schema),
      id: id(schema),
      attributes: attributes(schema),
      relationships: relationships(schema)
    }
  end

  defp attributes(schema) do
    primary_key = primary_key(schema)
    relationship_keys = associations(schema) ++ embeds(schema)

    attribute_keys =
      schema
      |> Map.keys()
      |> Kernel.--([:__meta__, :__struct__, primary_key])
      |> Kernel.--(relationship_keys)

    Map.take(schema, attribute_keys)
  end

  defp relationships(schema) do
    case associations(schema) ++ embeds(schema) do
      [] ->
        %{}

      relationship_attrbutes ->
        relationship_attrbutes
        |> Enum.reduce({%{}, schema}, &relationship/2)
    end
  end

  defp relationship(attribute, {acc, schema}) do
    associated_data =
      case Map.get(schema, attribute) do
        schemas when is_list(schemas) ->
          Enum.map(schemas, &resource_identifier_object(&1))

        %Ecto.Association.NotLoaded{} ->
          resource_identifier_object(schema, attribute)

        schema ->
          resource_identifier_object(schema)
      end

    Map.put(acc, attribute, %{data: associated_data})
  end

  defp resource_identifier_object(schema, attribute) do
    %{
      relationship: relationship,
      owner_key: owner_key,
      queryable: queryable
    } = association(schema, attribute)

    if relationship == :parent do
      %{id: Map.get(schema, owner_key), type: type(queryable)}
    end
  end

  defp resource_identifier_object(schema) do
    %{id: id(schema), type: type(schema)}
  end

  defp included(schema, acc) do
    case schema.__struct__.__schema__(:associations) do
      [] -> []
      associations -> Enum.reduce(associations, {acc, schema}, &included_data/2)
    end
  end

  defp included_data(association, {list, schema}) do
    associated_data = Map.get(schema, association)

    case associated_data do
      %Ecto.Association.NotLoaded{} ->
        list

      associated_data when is_list(associated_data) ->
        datas = Enum.map(associated_data, &resource_object/1)
        datas ++ list

      associated_data ->
        [resource_object(associated_data) | list]
    end
  end

  defp associations(schema), do: schema.__struct__.__schema__(:associations)
  defp embeds(schema), do: schema.__struct__.__schema__(:embeds)
  defp type(%{__meta__: %{source: source}}), do: source
  defp type(ecto_schema_module), do: ecto_schema_module.__schema__(:source)

  defp association(schema, key) do
    schema.__struct__.__schema__(:association, key)
  end

  defp primary_key(schema) do
    schema.__struct__.__schema__(:primary_key) |> List.first()
  end

  defp id(schema) do
    primary_key =
      schema.__struct__.__schema__(:primary_key)
      |> List.first()

    Map.get(schema, primary_key)
  end
end
