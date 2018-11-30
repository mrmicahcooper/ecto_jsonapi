defmodule User do
  use Ecto.Schema

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    has_many(:credit_cards, CreditCard)

    timestamps()
  end
end

defmodule CreditCard do
  use Ecto.Schema

  schema "credit_cards" do
    field(:number, :string)
    field(:expiration_date, :string)
    field(:cvv, :string)
    belongs_to(:user, User)
  end
end
