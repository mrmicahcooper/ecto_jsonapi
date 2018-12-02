defmodule Event do
  use Ecto.Schema

  schema "events" do
    field(:name, :string)
    field(:content, :map)

    timestamps()
  end
end
