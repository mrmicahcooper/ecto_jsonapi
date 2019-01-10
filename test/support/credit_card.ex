defmodule CreditCard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credit_cards" do
    field(:number, :string)
    field(:expiration_date, :string)
    field(:cvv, :string)
    belongs_to(:user, User)
  end

  def changeset(data, params) do
    data
    |> cast(params, ~w[number expiration_date cvv user_id]a)
    |> validate_length(:number, min: 9)
    |> validate_required([:cvv, :expiration_date])
  end

  def changeset(params) do
    %__MODULE__{}
    |> changeset(params)
  end
end
