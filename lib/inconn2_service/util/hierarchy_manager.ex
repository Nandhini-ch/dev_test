defmodule Inconn2Service.Util.HierarchyManager do
  import Ecto.Query
  import Ecto.Changeset

  def make_child_of(changeset, parent = %{id: id}) do
    new_path = parent.path ++ [id]
    changeset |> change(%{path: new_path})
  end

  def parent_id(node), do: List.last(node.path)

  def parent(node = %{__struct__: schema}) do
    p_id = parent_id(node)

    if p_id == nil do
      nil
    else
      from(n in schema, where: n.id == ^p_id)
    end
  end

  def root_id(node = %{path: []}), do: node.id
  def root_id(%{path: path}) when is_list(path), do: hd(path)

  def root?(%{path: []}), do: true
  def root?(%{path: path}) when is_list(path), do: false

  def ancestor_ids(%{path: path}) when is_list(path), do: path

  def ancestors(%{path: []}), do: []

  def ancestors(%{__struct__: schema, path: path}) when is_list(path) do
    from(n in schema, where: n.id in ^path)
  end

  def path_ids(%{id: id, path: path}) when is_list(path), do: path ++ [id]

  def path(node = %{__struct__: schema}) do
    pids = path_ids(node)
    from(n in schema, where: n.id in ^pids)
  end

  def children(node = %{__struct__: schema, path: path}) when is_list(path) do
    pids = path_ids(node)
    from(n in schema, where: fragment("(?) = ?", field(n, :path), ^pids))
  end

  def siblings(%{__struct__: schema, path: path}) when is_list(path) do
    from(n in schema, where: fragment("(?) = ?", field(n, :path), ^path))
  end

  def descendants(node = %{__struct__: schema}) do
    pids = path_ids(node)
    from(n in schema, where: fragment("? @> ?", field(n, :path), ^pids))
  end

  def subtree(node = %{__struct__: schema, id: id}) do
    pids = path_ids(node)
    from(n in schema, where: fragment("? @> ?", field(n, :path), ^pids) or n.id == ^id)
  end

  def depth(%{path: path}) when is_list(path), do: length(path)

  def build_tree(node_list) do
    depth_map = build_node_list_map_by_depth(node_list)
    min_level = Map.keys(depth_map) |> Enum.min()
    first_level_list = Map.get(depth_map, min_level, [])
    first_level_family = Map.delete(depth_map, min_level)
    Enum.reduce(first_level_list, [], &tree_from_family(&1, &2, first_level_family, min_level))
  end

  defp build_node_list_map_by_depth(node_list) do
    Enum.reduce(node_list, %{}, fn node, acc ->
      depth = depth(node)
      node_map = Map.delete(node, :__struct__)
      Map.put(acc, depth, Map.get(acc, depth, []) ++ [node_map])
    end)
  end

  defp tree_from_family(parent_node, built_list, family_map, level) do
    next_level = level + 1

    node_children =
      Map.get(family_map, next_level, [])
      |> Enum.filter(fn possible_child -> parent_id(possible_child) == parent_node.id end)
      |> Enum.reduce([], &tree_from_family(&1, &2, family_map, next_level))

    new_node = Map.put(parent_node, :children, node_children)
    built_list ++ [new_node]
  end
end
