defmodule CreditCard do
  use Ecto.Schema

  schema "credit_cards" do
    field(:number, :string)
    field(:expiration_date, :string)
    field(:cvv, :string)
    belongs_to(:user, User)
  end
end
