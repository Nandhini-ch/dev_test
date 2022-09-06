defmodule Inconn2ServiceWeb.DashboardsView do
  use Inconn2ServiceWeb, :view

  def render("high_level.json", %{data: data}) do
    %{
      data: data
    }
  end

  def render("detailed_charts.json", %{data: data}) do
    %{
      data: data
    }
  end

end
