defmodule EctoJsonapi.Load do
  @moduledoc """
    Use to convert an `Ecto.Schema` into JSON:API
  """

  @spec load([Ecto.Schema]) :: map
  @spec load(Ecto.Schema) :: map
  @spec load([Ecto.Schema], %{module => [atom]}) :: map
  @spec load(Ecto.Schema, %{module => [atom]}) :: map
  @doc """
  Convert `Ecto.Schema`s into a Json API map

  This looks at your schema and figures out how to convert it to the JSON:API V1.0 spec

  ## Options

  The following options are accepted:
  - `:attributes` - the attributes you want to return for each type of `Ecto.Schema`
  being loaded. This is a map where the key is a module name and the value is a list of fields.<br\> E.g.
  ` attributes: %{User => [:email, :name, :age]} `. Remember, the `:id` is not
  an attribute and is always returned.

  ## Example

  Let's say you have the following data:

  ```
  iex(1)>  user_with_credit_cards = %User{
  ...(1)>    id: 1,
  ...(1)>    name: "Micah Cooper",
  ...(1)>    email: "micah@example.com",
  ...(1)>    credit_cards: [
  ...(1)>      %CreditCard{
  ...(1)>        id: 456,
  ...(1)>        number: "4444 4444 4444 4444",
  ...(1)>        expiration_date: "2018-02",
  ...(1)>        cvv: "321",
  ...(1)>        user_id: 1
  ...(1)>      },
  ...(1)>      %CreditCard{
  ...(1)>        id: 789,
  ...(1)>        number: "5555 5555 5555 5555",
  ...(1)>        expiration_date: "2018-02",
  ...(1)>        cvv: "234",
  ...(1)>        user_id: 1
  ...(1)>      }
  ...(1)>    ]
  ...(1)>  }
  ...(1)> #Convert this to JSON:API. Only show the `User`'s email and name
  ...(1)> EctoJsonapi.Load.load(user_with_credit_cards,
  ...(1)>                       attributes: %{User => [:email]} )
  %{
   "data" => %{
     "attributes" => %{
       "email" => "micah@example.com"
     },
     "id" => 1,
     "relationships" => %{
       "credit-cards" => %{
         "data" => [
           %{"id" => 456, "type" => "credit_cards"},
           %{"id" => 789, "type" => "credit_cards"}
         ]
       }
     },
     "type" => "users",
     "links" => %{
       "credit-cards" => "/users/1/credit_cards",
       "events" => "/users/1/events"
       }
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
       "links" => %{"user" => "/users/1"},
       "type" => "credit_cards"
     },
     %{
       "attributes" => %{
         "cvv" => "234",
         "expiration-date" => "2018-02",
         "number" => "5555 5555 5555 5555",
         "user-id" => 1
       },
       "id" => 789,
       "relationships" => %{"user" => %{"data" => %{"id" => 1, "type" => "users"}}},
       "links" => %{"user" => "/users/1"},
       "type" => "credit_cards"
     }
   ]
  }
  ```
  """

  def load(%Ecto.Changeset{errors: errors}) do
    errors = Enum.map(errors, &error_format/1)
    %{"errors" => errors}
  end

  def load(ectos) when is_list(ectos), do: load(ectos, [])
  def load(ecto), do: load(ecto, [])

  def load(ectos, options) when is_list(ectos) do
    data = %{"data" => Enum.map(ectos, &resource_object(&1, options))}

    case Enum.reduce(ectos, [], &included/2) |> Enum.uniq() do
      [] -> data
      included -> Map.put(data, "included", included)
    end
  end

  def load(ecto, options) do
    data = %{"data" => resource_object(ecto, options)}

    case included(ecto, []) do
      [] -> data
      included -> Map.put(data, "included", included)
    end
  end

  defp resource_object(ecto, options \\ []) do
    relationships = relationships(ecto)
    links = links(ecto, options)

    data = %{
      "type" => type(ecto),
      "id" => id(ecto),
      "attributes" => attributes(ecto, options)
    }

    data =
      if relationships == %{} do
        data
      else
        Map.put(data, "relationships", relationships)
      end

    if links == %{} do
      data
    else
      Map.put(data, "links", links)
    end
  end

  defp attributes(ecto, options) do
    primary_key = primary_key(ecto)

    ignored_keys =
      [:__meta__, :__struct__, primary_key]
      |> Enum.concat(associations(ecto))
      |> Enum.concat(embeds(ecto))

    attribute_keys =
      case options[:attributes][ecto.__struct__] do
        nil -> Map.keys(ecto) -- ignored_keys
        attributes -> attributes -- ignored_keys
      end

    Map.take(ecto, attribute_keys)
    |> Enum.into(%{}, fn {k, v} -> {to_dash(k), v} end)
  end

  defp links(ecto, options) do
    case associations(ecto) do
      [] ->
        %{}

      relationship_attrbutes ->
        relationship_attrbutes
        |> Enum.reduce({%{}, ecto}, &link(&1, &2, options))
        |> elem(0)
    end
  end

  def link(attr, {acc, ecto}, options) do
    assoc = ecto.__struct__.__schema__(:association, attr)
    assoc_source = assoc.related.__schema__(:source)
    domain = get_in(options, [:links, :domain]) || "/"

    links =
      case assoc.cardinality do
        :one ->
          id = Map.get(ecto, assoc.owner_key) |> to_string()
          path = Path.join([domain, assoc_source, id])
          Map.put(acc, to_dash(attr), path)

        :many ->
          source = ecto.__struct__.__schema__(:source)
          primary_key = ecto.__struct__.__schema__(:primary_key) |> List.first()
          id = Map.get(ecto, primary_key) |> to_string()
          path = Path.join([domain, source, id, assoc_source])
          Map.put(acc, to_dash(attr), path)

        _ ->
          acc
      end

    {links, ecto}
  end

  defp relationships(ecto) do
    case associations(ecto) ++ embeds(ecto) do
      [] ->
        %{}

      relationship_attrbutes ->
        relationship_attrbutes
        |> Enum.reduce({%{}, ecto}, &relationship/2)
        |> elem(0)
    end
  end

  defp relationship(attribute, {acc, ecto}) do
    rels =
      case Map.get(ecto, attribute) do
        ectos when is_list(ectos) ->
          nested_resources = Enum.map(ectos, &resource_identifier_object(&1))
          Map.put(acc, to_dash(attribute), %{"data" => nested_resources})

        %Ecto.Association.NotLoaded{} ->
          resource_identifier = resource_identifier_object(ecto, attribute)

          if resource_identifier == %{} do
            acc
          else
            Map.put(acc, to_dash(attribute), %{"data" => resource_identifier})
          end

        ecto ->
          resource = resource_identifier_object(ecto)
          Map.put(acc, to_dash(attribute), %{"data" => resource})
      end

    {rels, ecto}
  end

  defp resource_identifier_object(ecto, attribute) do
    %{
      relationship: relationship,
      owner_key: owner_key
    } = assoc = association(ecto, attribute)

    queryable = Map.get(assoc, :queryable)
    id = Map.get(ecto, owner_key)

    if queryable && id && relationship == :parent do
      %{"id" => id, "type" => type(queryable)}
    else
      %{}
    end
  end

  defp resource_identifier_object(ecto) do
    %{"id" => id(ecto), "type" => type(ecto)}
  end

  defp included(ecto, acc) do
    case ecto.__struct__.__schema__(:associations) do
      [] ->
        []

      associations ->
        associations
        |> Enum.reduce({acc, ecto}, &included_data/2)
        |> elem(0)
    end
  end

  defp included_data(association, {list, ecto}) do
    associated_data = Map.get(ecto, association)

    case associated_data do
      %Ecto.Association.NotLoaded{} ->
        {list, ecto}

      associated_data when is_list(associated_data) ->
        datas = Enum.map(associated_data, &resource_object/1) ++ list
        {datas, ecto}

      associated_data ->
        datas = [resource_object(associated_data) | list]
        {datas, ecto}
    end
  end

  defp to_dash(key) do
    key
    |> to_string()
    |> String.replace("_", "-")
  end

  defp associations(ecto), do: ecto.__struct__.__schema__(:associations)
  defp embeds(ecto), do: ecto.__struct__.__schema__(:embeds)
  defp type(%{__meta__: %{source: source}}), do: source
  defp type(ecto_schema_module), do: ecto_schema_module.__schema__(:source)
  defp association(ecto, key), do: ecto.__struct__.__schema__(:association, key)

  defp primary_key(ecto) do
    ecto.__struct__.__schema__(:primary_key) |> List.first()
  end

  defp id(ecto) do
    primary_key = primary_key(ecto)
    Map.get(ecto, primary_key)
  end

  defp error_format({attr, detail}) do
    %{
      "detail" => detail(detail),
      "source" => %{
        "pointer" => "data/attributes/#{to_dash(attr)}"
      }
    }
  end

  def detail({message, values}) do
    Enum.reduce(values, message, fn {k, v}, acc ->
      key = k |> to_string() |> String.replace("_", "-")
      String.replace(acc, "%{#{key}}", to_string(v))
    end)
  end

  def detail(message), do: message
end
