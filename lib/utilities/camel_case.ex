defmodule EctoJsonapi.Utilities.Camelcase do
  @word_delimiters ["", " ", "_", "-", "."]

  def parse(string),
    do: parse(string, "", nil)

  def parse("", acc, _state), do: acc

  def parse(<<h::binary-1, t::binary>>, acc, :upcase),
    do: parse(t, acc <> String.upcase(h), nil)

  def parse(<<h::binary-1, t::binary>>, "", _state) when h in @word_delimiters,
    do: parse(t, "", nil)

  def parse(<<h::binary-1, t::binary>>, acc, _state) when h in @word_delimiters,
    do: parse(t, acc, :upcase)

  def parse(<<h::binary-1, t::binary>>, "", _state),
    do: parse(t, String.downcase(h), nil)

  def parse(<<h::binary-1, t::binary>>, acc, _state),
    do: parse(t, acc <> h, nil)
end
