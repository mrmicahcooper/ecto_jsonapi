defmodule EctoJsonapi do
  defdelegate load(ectos), to: EctoJsonapi.Load
  defdelegate load(ecto, options), to: EctoJsonapi.Load
  defdelegate dump(json), to: EctoJsonapi.Dump



  @spec attributes(Ecto.Schema, [atom]) :: map
  @doc """
  Return the selected attributes

  This function also:
  - Returns all the keys as strings
  - Converts any underscores (`_`) in the keys to dashes (`-`).
  """
  def attributes(schema, attributes) do
    for {key, value} <- Map.take(schema, attributes), into: %{} do
      key = to_string(key) |> String.replace("_", "-")
      {key, value}
    end
  end

end
