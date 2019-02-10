defmodule EctoJsonapi.Load do
  def load(ectos) when is_list(ectos), do: load(ectos, [])
  def load(ecto), do: load(ecto, [])

  def load(ectos, options) when is_list(ectos) do
    %{
      "data" => Enum.map(ectos, &resource_object(&1, options)),
      "included" => Enum.reduce(ectos, [], &included/2) |> Enum.uniq()
    }
  end

  def load(ecto, options) do
    %{
      "data" => resource_object(ecto, options),
      "included" => included(ecto, [])
    }
  end

  defp resource_object(ecto, options \\ []) do
    %{
      "type" => type(ecto),
      "id" => id(ecto),
      "attributes" => attributes(ecto, options),
      "relationships" => relationships(ecto)
    }
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

  defp relationships(ecto) do
    case associations(ecto) ++ embeds(ecto) do
      [] ->
        %{}

      relationship_attrbutes ->
        relationship_attrbutes |> Enum.reduce({%{}, ecto}, &relationship/2)
    end
  end

  defp relationship(attribute, {acc, ecto}) do
    associated_data =
      case Map.get(ecto, attribute) do
        ectos when is_list(ectos) ->
          Enum.map(ectos, &resource_identifier_object(&1))

        %Ecto.Association.NotLoaded{} ->
          resource_identifier_object(ecto, attribute)

        ecto ->
          resource_identifier_object(ecto)
      end

    Map.put(acc, to_dash(attribute), %{"data" => associated_data})
  end

  defp resource_identifier_object(ecto, attribute) do
    %{
      relationship: relationship,
      owner_key: owner_key,
      queryable: queryable
    } = association(ecto, attribute)

    if relationship == :parent do
      %{"id" => Map.get(ecto, owner_key), "type" => type(queryable)}
    end
  end

  defp resource_identifier_object(ecto) do
    %{"id" => id(ecto), "type" => type(ecto)}
  end

  defp included(ecto, acc) do
    case ecto.__struct__.__schema__(:associations) do
      [] -> []
      associations -> Enum.reduce(associations, {acc, ecto}, &included_data/2)
    end
  end

  defp included_data(association, {list, ecto}) do
    associated_data = Map.get(ecto, association)

    case associated_data do
      %Ecto.Association.NotLoaded{} ->
        list

      associated_data when is_list(associated_data) ->
        datas = Enum.map(associated_data, &resource_object/1)
        datas ++ list

      associated_data ->
        [resource_object(associated_data) | list]
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
end
