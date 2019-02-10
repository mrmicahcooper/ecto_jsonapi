defmodule EctoJsonapi.DumpTest do
  use ExUnit.Case, async: true

  describe "dump" do
    test "converting to ecto's format" do
      jsonapi = %{
        "data" => %{
          "id" => 99,
          "type" => "events",
          "attributes" => %{
            "name" => "foo",
            "content" => "here is the content"
          }
        }
      }

      params = EctoJsonapi.Dump.dump(jsonapi)

      assert params == %{
               "id" => 99,
               "name" => "foo",
               "content" => "here is the content"
             }
    end
  end
end