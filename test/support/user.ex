defmodule User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:age, :integer)
    field(:nick_name, :string)
    has_many(:credit_cards, CreditCard)
    has_many(:events, Event)

    timestamps()
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, ~w[name email age nick_name]a)
    |> cast_assoc(:credit_cards)
    |> validate_number(:age, greater_than: 21)
    |> validate_length(:name, min: 3)
    |> validate_required([:email, :nick_name])
  end
end
