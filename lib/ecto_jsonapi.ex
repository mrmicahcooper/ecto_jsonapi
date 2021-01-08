defmodule EctoJsonapi do
  defdelegate load(ectos), to: EctoJsonapi.Load
  defdelegate load(ecto, options), to: EctoJsonapi.Load
  defdelegate dump(json), to: EctoJsonapi.Dump

  def attributes(schema, attributes) do
    for {key, value} <- Map.take(schema, attributes), into: %{} do
      key = to_string(key) |> String.replace("_", "-")
      {key, value}
    end
  end

end
