# Hike
The `Hike` module provides an implementation of the Optional data types.
It defines

* a struct `Hike.Option` with a single field `value` which can either be `nil`
  or any other value of type `t`.

* a struct `Hike.Either` that represents an "either/or" value.
  It can contain either a `left` value or a `right` value, but not both

* a struct `Hike.MayFail`that represents an "either/or" value.
  It can contain either a `Failure` value or a `Success` value, but not both.

This implementation provides shorthand functions to work with Optional data, including mapping, filtering, applying and many more functions to the value
inside the Optional data.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `hike` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hike, "~> 0.0.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/hike>.

