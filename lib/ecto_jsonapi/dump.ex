defmodule EctoJsonapi.Dump do
  def dump(%{"data" => %{"attributes" => attrs, "id" => id}, "relationships" => rels}) do
    rels = Enum.into(rels, %{}, &relationship/1)

    Enum.into(attrs, %{}, &attr/1)
    |> Map.put("id", id)
    |> Map.merge(rels)
  end

  def dump(%{"data" => %{"attributes" => attrs, "id" => id}}) do
    attrs
    |> Enum.into(%{}, &attr/1)
    |> Map.put("id", id)
  end

  def dump(%{"data" => %{"attributes" => attrs}}) do
    Enum.into(attrs, %{}, &attr/1)
  end

  defp attr({key, value}) do
    key = to_string(key) |> String.replace("-", "_")

    {key, value}
  end

  defp relationship({item_name, %{} = params}) do
    id = get_in(params, ["data", "id"])
    {"#{item_name}_id", id}
  end
end
