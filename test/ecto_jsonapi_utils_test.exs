defmodule EctoJsonapi.UtilsUtilsTest do
  use ExUnit.Case, async: true
  doctest EctoJsonapi.Utils

  setup do
    {:ok,
     %{
       empty_data: File.read!("test/support/fixtures/jsonapi/empty_data.json") |> Jason.decode!(),
       one_data:
         File.read!("test/support/fixtures/jsonapi/singular_data.json") |> Jason.decode!(),
       multiple_data: File.read!("test/support/fixtures/jsonapi/jsonapi.json") |> Jason.decode!()
     }}
  end

  describe "has_id?" do
    test "with no data", %{empty_data: json} do
      assert EctoJsonapi.Utils.has_id?(json, "1") == false
    end

    test "with one data element", %{one_data: json} do
      assert EctoJsonapi.Utils.has_id?(json, "1") == true
    end

    test "with multiple data elements", %{multiple_data: json} do
      assert EctoJsonapi.Utils.has_id?(json, "1") == true
      assert EctoJsonapi.Utils.has_id?(json, ["1"]) == true
    end
  end

  describe "has_type?" do
    test "with no data", %{empty_data: json} do
      assert EctoJsonapi.Utils.has_type?(json, "articles") == false
    end

    test "with one data element", %{one_data: json} do
      assert EctoJsonapi.Utils.has_type?(json, "articles") == true
    end

    test "with multiple data elements", %{multiple_data: json} do
      assert EctoJsonapi.Utils.has_type?(json, "articles") == true
    end
  end

  describe "has_attribute?" do
    test "with no data", %{empty_data: json} do
      assert EctoJsonapi.Utils.has_attribute?(json, "title") == false
    end

    test "with one data element", %{one_data: json} do
      assert EctoJsonapi.Utils.has_attribute?(json, "title") == true
    end

    test "with multiple data elements", %{multiple_data: json} do
      assert EctoJsonapi.Utils.has_attribute?(json, "title") == true
    end
  end

  describe "has_relationship?" do
    test "with no data", %{empty_data: json} do
      assert(EctoJsonapi.Utils.has_relationship?(json, "author") == false)
    end

    test "with one data element", %{one_data: json} do
      assert(EctoJsonapi.Utils.has_relationship?(json, "author") == true)
    end

    test "with multiple data elements", %{multiple_data: json} do
      assert(EctoJsonapi.Utils.has_relationship?(json, "author") == true)
    end
  end
end

# test "with no data", %{empty_data: json} do
# end

# test "with one data element", %{one_data: json} do
# end

# test "with multiple data elements", %{multiple_data: json} do
# end
