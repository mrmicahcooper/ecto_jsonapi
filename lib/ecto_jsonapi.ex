defmodule EctoJsonapi do
  def to_json(schemas) when is_list(schemas) do
    %{
      data: Enum.map(schemas, &data/1)
    }
  end

  def to_json(schema) do
    %{
      data: data(schema),
      included: included(schema),
      meta: %{}
    }
  end

  defp data(schema) do
    default_data = %{
      type: type(schema),
      id: nil,
      attributes: %{},
      relationships: %{}
    }

    schema_map = Map.from_struct(schema)

    {data, _schema} = Enum.reduce(schema_map, {default_data, schema}, &data/2)

    data
  end

  defp type(%{__meta__: %{source: source}}), do: source
  defp type(ecto_schema_module), do: ecto_schema_module.__schema__(:source)

  defp data({:id, id}, {doc, schema}), do: {Map.put(doc, :id, id), schema}
  defp data({:__meta__, _}, acc), do: acc
  defp data({:__struct__, _}, acc), do: acc

  defp data({key, %Ecto.Association.NotLoaded{}}, {doc, schema}) do
    relationship = relationship(schema, key)
    {put_in(doc, [:relationships, key], relationship), schema}
  end

  # only add the relationship part of a associated schema. The `included` part is added later
  defp data({key, %{__struct__: _}}, {doc, schema}) do
    relationship = relationship(schema, key)
    {put_in(doc, [:relationships, key], relationship), schema}
  end

  defp data({key, value}, {doc, schema}) do
    {put_in(doc, [:attributes, key], value), schema}
  end

  defp included(schema) do
    associations = schema.__struct__.__schema__(:associations)
    Enum.reduce(associations, {[], schema}, &included_data/2)
  end

  defp included_data(association, {list, schema}) when not is_list(association) do
    associated_data = Map.get(schema, association)

    if associated_data.__struct__ == Ecto.Association.NotLoaded do
      list
    else
      [data(associated_data) | list]
    end
  end

  defp relationship(schema, key) do
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
