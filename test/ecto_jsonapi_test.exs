defmodule EctoJsonapiTest do
  use ExUnit.Case, async: true

  setup do
    event = %Event{
      id: 123,
      name: "foo",
      content: %{foo: "bar"}
    }

    credit_card = %CreditCard{
      id: 456,
      number: "4444 4444 4444 4444",
      expiration_date: "2018-02",
      cvv: "123",
      user_id: 123
    }

    user = %User{
      id: 456,
      name: "Micah Cooper",
      email: "mrmicahcooper@gmail.com"
    }

    credit_card_with_user = %CreditCard{
      id: 456,
      number: "4444 4444 4444 4444",
      expiration_date: "2018-02",
      cvv: "123",
      user_id: user.id,
      user: user
    }

    {:ok,
     %{
       user: user,
       event: event,
       credit_card: credit_card,
       credit_card_with_user: credit_card_with_user
     }}
  end

  describe "to_json" do
    test "1 schema with no associations", data do
      json = EctoJsonapi.to_json(data.event)

      assert get_in(json, [:data, :attributes, :name])
      assert get_in(json, [:data, :attributes, :content])
      assert get_in(json, [:data, :id])
      assert get_in(json, [:data, :type]) == "events"
      assert get_in(json, [:data, :relationships]) == %{}
    end

    test "2 schemas with no associations", data do
      json = EctoJsonapi.to_json([data.event, data.event])

      assert get_in(json.data, [Access.all(), :attributes, :name]) == ["foo", "foo"]

      assert get_in(json.data, [Access.all(), :attributes, :content]) == [
               %{foo: "bar"},
               %{foo: "bar"}
             ]

      assert get_in(json.data, [Access.all(), :relationships]) == [%{}, %{}]
      assert get_in(json.data, [Access.all(), :included]) == [nil, nil]
    end

    test "1 schema with an unloaded but present belongs_to", data do
      json = EctoJsonapi.to_json(data.credit_card)

      assert json.data.relationships.user == %{
               data: %{
                 type: "users",
                 id: 123
               }
             }
    end

    test "1 schema with a loaded belongs to", data do
      json = EctoJsonapi.to_json(data.credit_card_with_user)

      assert json.data.relationships.user == %{
               data: %{
                 type: "users",
                 id: data.user.id
               }
             }

      assert get_in(json.included, [Access.all(), :id]) == [data.user.id]
      assert get_in(json.included, [Access.all(), :attributes, :name]) == [data.user.name]
    end
  end
end
