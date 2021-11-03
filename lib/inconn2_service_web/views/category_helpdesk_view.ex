defmodule Inconn2ServiceWeb.CategoryHelpdeskView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.CategoryHelpdeskView

  def render("index.json", %{category_helpdesks: category_helpdesks}) do
    %{data: render_many(category_helpdesks, CategoryHelpdeskView, "category_helpdesk.json")}
  end

  def render("show.json", %{category_helpdesk: category_helpdesk}) do
    %{data: render_one(category_helpdesk, CategoryHelpdeskView, "category_helpdesk.json")}
  end

  def render("category_helpdesk.json", %{category_helpdesk: category_helpdesk}) do
    %{id: category_helpdesk.id,
      user_id: category_helpdesk.user_id}
  end
end
