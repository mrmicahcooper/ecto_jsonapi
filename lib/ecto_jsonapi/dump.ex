defmodule EctoJsonapi.Dump do
  def dump(%{"data" => %{"attributes" => attrs, "id" => id}}) do
    Map.put(attrs, "id", id)
  end

  def dump(%{"data" => %{"attributes" => attrs}}), do: attrs
end
