defmodule EctoJsonapi do
  def to_json(schemas) when is_list(schemas) do
    %{
      data: Enum.map(schemas, &data/1)
    }
  end

  def to_json(schema) do
    %{data: data(schema)}
  end

  defp data(schema) do
    default_data = %{
      type: type(schema),
      id: nil,
      attributes: %{},
      relationships: %{}
    }

    {default_data, schema}

    {data, _schema} =
      schema
      |> Map.from_struct()
      |> Enum.reduce({default_data, schema}, &data/2)

    data
  end

  defp type(%{__meta__: %{source: source}}), do: source
  defp type(ecto_schema_module), do: ecto_schema_module.__schema__(:source)

  defp data({:id, id}, {doc, schema}) do
    {Map.put(doc, :id, id), schema}
  end

  defp data({:__meta__, _}, acc), do: acc
  defp data({:__struct__, _}, acc), do: acc

  defp data({key, %Ecto.Association.NotLoaded{}}, {doc, schema}) do
    association = schema.__struct__.__schema__(:association, key)
    type = type(association.queryable)
    owner_key = association.owner_key

    relationship = %{
      data: %{
        type: type,
        id: Map.get(schema, owner_key)
      }
    }

    {put_in(doc, [:relationships, key], relationship), schema}
  end

  defp data({key, value}, {doc, schema}) do
    {put_in(doc, [:attributes, key], value), schema}
  end
end
