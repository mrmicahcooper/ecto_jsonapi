defmodule EctoJsonapi do
  def load(ectos) when is_list(ectos), do: EctoJsonapi.Load.load(ectos)
  def load(ecto, options \\ []), do: EctoJsonapi.Load.load(ecto, options)

  def dump(json), do: EctoJsonapi.Dump.dump(json)
end
