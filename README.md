## Ecto JSON:API 
EctoJsonapi is tool for dealing with JSON:API and Ecto schemas:
1) `EctoJsonApi.dump/1` Convert JSON:API v1.0 into Ecto friendly maps .
2) `EctoJsonApi.load/2` Convert Ecto schemas into maps structured like JSON:API v1.0.

## Install into a Phoenix or other Elixir/Ecto application:

Add `:ecto_jsonapi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_jsonapi, "~> 0.2.0"},
  ]
end
```

## Example/ Usage
  Let's say you have the following data:
  ```
    user_with_credit_cards = %User{
    id: 1,
      name: "Micah Cooper",
      email: "micah@example.com",
      credit_cards: [
        %CreditCard{
          id: 456,
          number: "4444 4444 4444 4444",
          expiration_date: "2018-02",
          cvv: "321",
          user_id: 1
        }
      ]
    }
   #Convert this to Jsonapi. Only show the `User`'s email and name
   EctoJsonapi.Load.load(user_with_credit_cards,
                         attributes: %{User => [:email]} )
```
```elixir
  %{
   "data" => %{
     "attributes" => %{
       "email" => "test@example.com"
     },
     "id" => 1,
     "relationships" => %{
       "credit-cards" => %{
         "data" => [
           %{"id" => 456, "type" => "credit_cards"}
         ]
       }
     },
     "type" => "users"
   },
   "included" => [
     %{
       "attributes" => %{
         "cvv" => "321",
         "expiration-date" => "2018-02",
         "number" => "4444 4444 4444 4444",
         "user-id" => 1
       },
       "id" => 456,
       "relationships" => %{"user" => %{"data" => %{"id" => 1, "type" => "users"}}},
       "type" => "credit_cards"
     }
   ]
  }
```
