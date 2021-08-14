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
end
