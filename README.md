# EctoJsonapi

EctoJsonapi is tool for dealing with JsonAPI and Ecto schemas
It:
- Converts Ecto schemas into elixir maps structured like JsonApi v1.0 with
  the `EctoJsonapi.Load/2`
- Converts elixir maps that are structured like JsonApi v1.0 into maps
  structured like Ecto schemas with `EctoJsonapi.Dump/1`
