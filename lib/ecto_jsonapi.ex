defmodule EctoJsonapi do
  def to_json(schemas) when is_list(schemas) do
    %{
      data: Enum.map(schemas, &data/1)
    }
  end

  def to_json(schema) do
    %{
      data: data(schema)
    }
  end

  defp data(schema) do
    %{
      id: id(schema),
      attributes: attributes(schema)
    }
  end

  defp id(schema) do
    schema.id
  end

  defp attributes(schema) do
    Map.drop(schema, [:__meta__, :__struct__])
  end
end
