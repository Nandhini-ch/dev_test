defmodule Inconn2ServiceWeb.SiteStockView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.SiteStockView

  def render("index.json", %{site_stocks: site_stocks}) do
    %{data: render_many(site_stocks, SiteStockView, "site_stock.json")}
  end

  def render("show.json", %{site_stock: site_stock}) do
    %{data: render_one(site_stock, SiteStockView, "site_stock.json")}
  end

  def render("site_stock.json", %{site_stock: site_stock}) do
    %{id: site_stock.id,
      quantity: site_stock.quantity,
      is_msl_breached: site_stock.is_msl_breached,
      breached_date_time: site_stock.breached_date_time}
  end
end
