defmodule EctoJsonapiTest do
  use ExUnit.Case, async: true

  setup do
    {:ok,
     %{
       event: %Event{
         id: 123,
         name: "foo",
         content: %{foo: "bar"}
       },
       credit_card: %CreditCard{
         id: 456,
         number: "4444 4444 4444 4444",
         expiration_date: "2018-02",
         cvv: "123",
         user_id: 123
       }
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
  end
end
