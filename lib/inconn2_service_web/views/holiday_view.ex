defmodule Inconn2ServiceWeb.HolidayView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.HolidayView

  def render("index.json", %{bankholidays: bankholidays}) do
    %{data: render_many(bankholidays, HolidayView, "holiday.json")}
  end

  def render("show.json", %{holiday: holiday}) do
    %{data: render_one(holiday, HolidayView, "holiday.json")}
  end

  def render("holiday.json", %{holiday: holiday}) do
    %{id: holiday.id,
      name: holiday.name,
      start_date: holiday.start_date,
      end_date: holiday.end_date}
  end
end
