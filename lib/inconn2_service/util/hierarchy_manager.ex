defmodule Inconn2Service.Util.HierarchyManager do
  import Ecto.Query
  import Ecto.Changeset

  def make_child_of(changeset, parent = %{id: id}) do
    new_path = parent.path ++ [id]
    changeset |> change(%{path: new_path})
  end

  def parent_id(node), do: List.last(node.path)

  def parent(type, node) do
    p_id = parent_id(node)

    if p_id == nil do
      nil
    else
      from(n in type, where: n.id == ^p_id)
    end
  end
end
