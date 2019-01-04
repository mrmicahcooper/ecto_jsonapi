defmodule EctoJsonapi do
  def to_json(ectos) when is_list(ectos) do
    %{
      data: Enum.map(ectos, &resource_object/1),
      included: Enum.reduce(ectos, [], &included/2) |> Enum.uniq()
    }
  end

  def to_json(ecto) do
    %{
      data: resource_object(ecto),
      included: included(ecto, [])
    }
  end

  def resource_object(ecto) do
    %{
      type: type(ecto),
      id: id(ecto),
      attributes: attributes(ecto),
      relationships: relationships(ecto)
    }
  end

  defp attributes(ecto) do
    primary_key = primary_key(ecto)
    ignored_keys = [:__meta__, :__struct__, primary_key] ++ associations(ecto) ++ embeds(ecto)
    attribute_keys = Map.keys(ecto) -- ignored_keys

    Map.take(ecto, attribute_keys)
  end

  defp relationships(ecto) do
    case associations(ecto) ++ embeds(ecto) do
      [] ->
        %{}

      relationship_attrbutes ->
        relationship_attrbutes
        |> Enum.reduce({%{}, ecto}, &relationship/2)
    end
  end

  defp relationship(attribute, {acc, ecto}) do
    associated_data =
      case Map.get(ecto, attribute) do
        ectos when is_list(ectos) ->
          Enum.map(ectos, &resource_identifier_object(&1))

        %Ecto.Association.NotLoaded{} ->
          resource_identifier_object(ecto, attribute)

        ecto ->
          resource_identifier_object(ecto)
      end

    Map.put(acc, attribute, %{data: associated_data})
  end

  defp resource_identifier_object(ecto, attribute) do
    %{
      relationship: relationship,
      owner_key: owner_key,
      queryable: queryable
    } = association(ecto, attribute)

    if relationship == :parent do
      %{id: Map.get(ecto, owner_key), type: type(queryable)}
    end
  end

  defp resource_identifier_object(ecto) do
    %{id: id(ecto), type: type(ecto)}
  end

  defp included(ecto, acc) do
    case ecto.__struct__.__schema__(:associations) do
      [] -> []
      associations -> Enum.reduce(associations, {acc, ecto}, &included_data/2)
    end
  end

  defp included_data(association, {list, ecto}) do
    associated_data = Map.get(ecto, association)

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

  defp associations(ecto), do: ecto.__struct__.__schema__(:associations)
  defp embeds(ecto), do: ecto.__struct__.__schema__(:embeds)
  defp type(%{__meta__: %{source: source}}), do: source
  defp type(ecto_schema_module), do: ecto_schema_module.__schema__(:source)

  defp association(ecto, key) do
    ecto.__struct__.__schema__(:association, key)
  end

  defp primary_key(ecto) do
    ecto.__struct__.__schema__(:primary_key) |> List.first()
  end

  defp id(ecto) do
    primary_key =
      ecto.__struct__.__schema__(:primary_key)
      |> List.first()

    Map.get(ecto, primary_key)
  end
end
