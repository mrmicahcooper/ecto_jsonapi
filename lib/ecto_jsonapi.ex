defmodule EctoJsonapi do
  defdelegate load(ectos), to: EctoJsonapi.Load
  defdelegate load(ecto, options), to: EctoJsonapi.Load
  defdelegate dump(json), to: EctoJsonapi.Dump
end
