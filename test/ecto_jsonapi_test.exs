defmodule EctoJsonapiTest do
  use ExUnit.Case, async: true

  setup do
    event = %Event{
      id: 123,
      name: "foo",
      content: %{foo: "bar"}
    }

    {:ok, %{event: event}}
  end

  describe "to_json" do
    test "1 schema with no associations", data do
      json = EctoJsonapi.to_json(data.event)

      assert get_in(json, [:data, :attributes, :name])
      assert get_in(json, [:data, :attributes, :content])
      assert get_in(json, [:data, :id])
      refute get_in(json, [:data, :relationships])
      refute get_in(json, [:data, :included])
    end

    test "2 schemas with no associations", data do
      json = EctoJsonapi.to_json([data.event, data.event])

      assert get_in(json.data, [Access.all(), :attributes, :name]) == ["foo", "foo"]

      assert get_in(json.data, [Access.all(), :attributes, :content]) == [
               %{foo: "bar"},
               %{foo: "bar"}
             ]

      assert get_in(json.data, [Access.all(), :relationships]) == [nil, nil]
      assert get_in(json.data, [Access.all(), :included]) == [nil, nil]
    end
  end
end
