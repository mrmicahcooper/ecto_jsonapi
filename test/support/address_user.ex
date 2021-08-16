defmodule AddressUser do
  use Ecto.Schema

  schema "addresses_users" do
    belongs_to(:user, User)
    belongs_to(:address, Address)

    timestamps()
  end
end
