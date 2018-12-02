defmodule User do
  use Ecto.Schema

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    has_many(:credit_cards, CreditCard)

    timestamps()
  end
end