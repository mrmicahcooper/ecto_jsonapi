defmodule EctoJsonapi.Utils do
  def has_id?(%{"data" => []}, _) do
    false
  end

  def has_id?(%{"data" => data}, ids) when is_list(data) and is_list(ids) do
    ids -- get_in(data, [Access.all(), "id"]) == []
  end

  def has_id?(%{"data" => data}, id) when is_list(data) do
    ids = get_in(data, [Access.all(), "id"])
    id in ids
  end

  def has_id?(%{"data" => data}, id) do
    get_in(data, ["id"]) == id
  end

  def has_id?(_, _) do
    false
  end

  def has_type?(%{"data" => []}, _) do
    false
  end

  def has_type?(%{"data" => [data | _]}, type) do
    Map.get(data, "type") == type
  end

  def has_type?(%{"data" => data}, type) do
    get_in(data, ["type"]) == type
  end

  def has_type?(_, _) do
    false
  end

  def has_attribute?(%{"data" => []}, _) do
    false
  end

  def has_attribute?(%{"data" => %{"attributes" => attrs}}, attr) do
    Map.has_key?(attrs, attr)
  end

  def has_attribute?(%{"data" => [%{"attributes" => attrs} | _]}, attr) do
    Map.has_key?(attrs, attr)
  end

  def has_attribute(_, _) do
    false
  end

  def has_relationship?(%{"data" => %{"relationships" => rels}}, rel) do
    Map.has_key?(rels, rel)
  end

  def has_relationship?(%{"data" => [%{"relationships" => rels} | _]}, rel) do
    Map.has_key?(rels, rel)
  end

  def has_relationship?(_data, _rel) do
    false
  end
end
