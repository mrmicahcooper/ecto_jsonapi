defmodule EctoJsonapi do
  def to_json(schemas) when is_list(schemas) do
    %{
      data: Enum.map(schemas, &resource_object/1)
    }
  end

  def to_json(schema) do
    %{
      data: resource_object(schema),
      included: included(schema),
      meta: %{}
    }
  end

  defp resource_object(schema) do
    default_data = %{
      type: type(schema),
      id: nil,
      attributes: %{},
      relationships: %{}
    }

    schema_map = Map.from_struct(schema)

    {resource_object, _schema} =
      Enum.reduce(schema_map, {default_data, schema}, &resource_object/2)

    resource_object
  end

  defp type(%{__meta__: %{source: source}}), do: source
  defp type(ecto_schema_module), do: ecto_schema_module.__schema__(:source)

  defp resource_object({:id, id}, {doc, schema}), do: {Map.put(doc, :id, id), schema}
  defp resource_object({:__meta__, _}, acc), do: acc
  defp resource_object({:__struct__, _}, acc), do: acc

  defp resource_object({key, %Ecto.Association.NotLoaded{}}, {doc, schema}) do
    relationship = resource_identifier_object(schema, key)
    {put_in(doc, [:relationships, key], relationship), schema}
  end

  # only add the relationship part of a belongs_to. The `included` part is added later
  defp resource_object({key, %{__struct__: _}}, {doc, schema}) do
    relationship = resource_identifier_object(schema, key)
    {put_in(doc, [:relationships, key], relationship), schema}
  end

  # skip has_many
  defp resource_object({key, [%{__struct__: _} | _] = children_schema}, {doc, schema}) do
    relationships =
      Enum.map(children_schema, fn schema ->
        %{
          type: type(schema),
          id: schema.id
        }
      end)

    resource_identifier_objects = %{data: relationships}

    {put_in(doc, [:relationships, key], resource_identifier_objects), schema}
  end

  defp resource_object({key, value}, {doc, schema}) do
    {put_in(doc, [:attributes, key], value), schema}
  end

  defp included(schema) do
    associations = schema.__struct__.__schema__(:associations)
    Enum.reduce(associations, {[], schema}, &included_data/2)
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

  defp resource_identifier_object(schema, key) do
    association = schema.__struct__.__schema__(:association, key)
    type = type(association.queryable)
    owner_key = association.owner_key

    %{
      data: %{
        type: type,
        id: Map.get(schema, owner_key)
      }
    }
  end
end
