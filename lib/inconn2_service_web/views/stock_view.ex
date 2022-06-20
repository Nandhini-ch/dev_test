defmodule Inconn2ServiceWeb.StockView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.StockView

  def render("index.json", %{stocks: stocks}) do
    %{data: render_many(stocks, StockView, "stock.json")}
  end

  def render("show.json", %{stock: stock}) do
    %{data: render_one(stock, StockView, "stock.json")}
  end

  def render("stock.json", %{stock: stock}) do
    %{id: stock.id,
      aisle: stock.aisle,
      row: stock.row,
      bin: stock.bin}
  end
end
