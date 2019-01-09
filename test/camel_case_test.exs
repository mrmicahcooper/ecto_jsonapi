defmodule CamelcaseTest do
  use ExUnit.Case, async: true

  import EctoJsonapi.Utilities.Camelcase

  describe "parse/1" do
    test "lowercase string", do: assert(parse("foo") == "foo")
    test "skid", do: assert(parse("foo_bar") == "fooBar")
    test "words with a space", do: assert(parse("foo bar") == "fooBar")
    test "parameterized", do: assert(parse("foo-bar") == "fooBar")
    test "skid with preceeding skid", do: assert(parse("_foo_bar") == "fooBar")
    test "dash with preceeding dash", do: assert(parse("-foo-bar") == "fooBar")
    test "Upper Camelized", do: assert(parse("FooBar") == "fooBar")
  end
end
