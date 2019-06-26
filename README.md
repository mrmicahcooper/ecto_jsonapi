## Ecto. Json.  Api.
Ecto => Json (Api)
<br/>Convert an ecto schema into json.

## Nitty Gritty

EctoJsonapi is tool for dealing with JsonAPI and Ecto schemas:
1) `EctoJsonApi.Dump/1` Converts elixir maps Ecto schemas.
2) `EctoJsonApi.Dump/1` Converts JsonApi v1.0 syntax into Ecto schemas.
3) `EctoJsonApi.Load/2` Converts Ecto schemas into elixir maps structured like JsonApi v1.0.

## Install into a Phoenix or other Elixir/Ecto application:
```bash
cd <Your Project that contains a mix.exs file.>;
{
  mix local.hex <<< Y;
  curl -s -O https://github.com/bryanstearns/mix_deps_add/releases/download/0.1.3/mix_deps_add-0.1.3.ez &&
  mix archive.install ./mix_deps_add-0.1.3.ez <<< Y 2>/dev/null;
  rm -rf mix_deps_add-0.1.3.ez;
  mix deps.add ecto_jsonapi;
  git status;
}
```

This application is meant to be used with Phoenix or other Elixir application.
If you need an example phoenix application checkout: [ecto_workshop](https://github.com/jax-ex-public-repos/ecto_workshop)

## Example/ Usage
```elixir
user = %User{
  id: 456,
  name: "Micah Cooper",
  email: "mrmicahcooper@gmail.com"
}
data = {:ok,
  %{
    user: user,
  }
}
json = EctoJsonapi.Load.load(data)
assert get_in(json, ["data", "attributes", "content"])
```

For a more indepth example checkout the [test suite](https://github.com/mrmicahcooper/ecto_jsonapi/blob/master/test/ecto_jsonapi/load_test.exs)


## Contribute
Micah really likes this project and is looking for contributors.

Are you using the project? Feel free to leave an Issue to show your support: [issue](https://github.com/mrmicahcooper/ecto_jsonapi/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc)
