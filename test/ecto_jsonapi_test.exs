defmodule EctoJsonapiTest do
  use ExUnit.Case, async: true

  setup do
    event = %Event{
      id: 123,
      name: "foo",
      content: %{foo: "bar"}
    }

    user = %User{
      id: 456,
      name: "Micah Cooper",
      email: "mrmicahcooper@gmail.com"
    }

    credit_card = %CreditCard{
      id: 456,
      number: "4444 4444 4444 4444",
      expiration_date: "2018-02",
      cvv: "123",
      user_id: user.id
    }

    credit_card_with_user = %CreditCard{
      id: 456,
      number: "4444 4444 4444 4444",
      expiration_date: "2018-02",
      cvv: "321",
      user_id: user.id,
      user: user
    }

    credit_card_with_user_2 = %CreditCard{
      id: 789,
      number: "5555 5555 5555 5555",
      expiration_date: "2018-02",
      cvv: "234",
      user_id: user.id,
      user: user
    }

    user_with_credit_cards = %User{
      id: user.id,
      name: "Micah Cooper",
      email: "mrmicahcooper@gmail.com",
      credit_cards: [
        credit_card_with_user,
        credit_card_with_user_2
      ]
    }

    {:ok,
     %{
       user: user,
       event: event,
       credit_card: credit_card,
       credit_card_with_user: credit_card_with_user,
       user_with_credit_cards: user_with_credit_cards
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
                 id: data.user.id
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

    test "2 schemas each with the same loaded belongs to", data do
      json =
        EctoJsonapi.to_json([
          data.credit_card_with_user,
          data.credit_card_with_user
        ])

      assert get_in(json.data, [Access.all(), :relationships, :user, :data, :id]) == [
               data.user.id,
               data.user.id
             ]

      assert get_in(json.included, [Access.all(), :id]) == [data.user.id]
      assert get_in(json.included, [Access.all(), :attributes, :email]) == [data.user.email]
    end

    test "1 schema with loaded has_many", data do
      json = EctoJsonapi.to_json(data.user_with_credit_cards)

      assert get_in(json.data.relationships.credit_cards.data, [Access.all(), :id]) == [
               456,
               789
             ]

      assert get_in(json.included, [Access.all(), :attributes, :number]) == [
               "4444 4444 4444 4444",
               "5555 5555 5555 5555"
             ]

      assert get_in(json.included, [Access.all(), :attributes, :cvv]) == [
               "321",
               "234"
             ]
    end

    test "2 schemas with loaded has many", data do
      json = EctoJsonapi.to_json([data.user_with_credit_cards, data.user_with_credit_cards])

      assert get_in(json.data, [
               Access.all(),
               :relationships,
               :credit_cards,
               :data,
               Access.all(),
               :id
             ])
             |> List.flatten() == [456, 789, 456, 789]

      assert get_in(json.included, [Access.all(), :attributes, :number]) == [
               "4444 4444 4444 4444",
               "5555 5555 5555 5555"
             ]

      assert get_in(json.included, [Access.all(), :attributes, :cvv]) == [
               "321",
               "234"
             ]
    end
  end
end
