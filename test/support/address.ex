defmodule Address do
  use Ecto.Schema

  schema "addresses" do
    field(:zipcode, :string)

    timestamps()
  end
end
