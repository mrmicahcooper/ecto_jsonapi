defmodule EctoJsonapi.DumpTest do
  use ExUnit.Case, async: true

  describe "dump" do
    test "converting to ecto's format" do
      jsonapi = %{
        "data" => %{
          "id" => 99,
          "type" => "events",
          "attributes" => %{
            "first-name" => "foo",
            "content" => "here is the content"
          }
        },
        "relationships" => %{
          "user" => %{
            "data" => %{"type" => "users", "id" => "123"}
          },
          "profile" => %{
            "data" => %{"type" => "profiles", "id" => "456"}
          }
        }
      }

      params = EctoJsonapi.Dump.dump(jsonapi)

      assert params == %{
               "id" => 99,
               "first_name" => "foo",
               "content" => "here is the content",
               "user_id" => "123",
               "profile_id" => "456"
             }
    end
  end
end
