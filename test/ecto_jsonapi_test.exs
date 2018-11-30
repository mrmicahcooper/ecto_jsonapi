defmodule Ecto_JsonapiTest do
  use ExUnit.Case, async: true

  setup do
    credit_card = %CreditCard{
      number: "2222333344445555",
      expiration_date: "2018-05",
      cvv: "123"
    }

    {:ok, credit_card}
  end

  describe "to_json" do
    test "with a single schema" do
    end
  end
end
