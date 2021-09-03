defmodule Inconn2ServiceWeb.CheckListView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.CheckListView

  def render("index.json", %{check_lists: check_lists}) do
    %{data: render_many(check_lists, CheckListView, "check_list.json")}
  end

  def render("show.json", %{check_list: check_list}) do
    %{data: render_one(check_list, CheckListView, "check_list.json")}
  end

  def render("check_list.json", %{check_list: check_list}) do
    %{id: check_list.id,
      name: check_list.name,
      type: check_list.type,
      check_ids: check_list.check_ids}
  end
end
