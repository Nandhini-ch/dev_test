defmodule Inconn2ServiceWeb.CheckView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.{CheckView, CheckTypeView}

  def render("index.json", %{checks: checks}) do
    %{data: render_many(checks, CheckView, "check.json")}
  end

  def render("show.json", %{check: check}) do
    %{data: render_one(check, CheckView, "check.json")}
  end

  def render("check.json", %{check: check}) do
    %{id: check.id,
      label: check.label,
      check_type: render_one(check.check_type, CheckTypeView, "check_type.json")}
  end
end
