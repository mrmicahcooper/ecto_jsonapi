defmodule Event do
  use Ecto.Schema

  schema "events" do
    field(:name, :string)
    field(:content, :map)
    belongs_to(:user, User)

    timestamps()
  end
end
