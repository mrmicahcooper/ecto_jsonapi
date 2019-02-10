defmodule EctoJsonapi.Dump do
  def dump(%{"data" => %{"attributes" => attrs, "id" => id}}) do
    attrs
    |> Map.put("id", id)
    |> Enum.into(%{}, fn {k, v} -> {to_skid(k), v} end)
  end

  def dump(%{"data" => %{"attributes" => attrs}}) do
    attrs
    |> Enum.into(%{}, fn {k, v} -> {to_skid(k), v} end)
  end

  defp to_skid(key) do
    key
    |> to_string()
    |> String.replace("-", "_")
  end
end
