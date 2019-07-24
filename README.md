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
  Let's say you have the following Ecto schema data:
  ```elixir
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

```
You can convert `user_with_credit_cards` to JSON:API.
Say you only want to return the `User`'s `email` and you only want the
`expiration_date`, and `cvv` from the `CreditCard`

```elixir
 EctoJsonapi.load(user_with_credit_cards, 
   attributes: %{
     User => [:email],
     CreditCard => [:expiration_date, :cvv]
   } 
 )
```
Resulting in:
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
         "expiration-date" => "2018-02"
       },
       "id" => 456,
       "relationships" => %{"user" => %{"data" => %{"id" => 1, "type" => "users"}}},
       "type" => "credit_cards"
     }
   ]
  }
```
