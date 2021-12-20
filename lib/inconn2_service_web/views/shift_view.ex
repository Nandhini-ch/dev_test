defmodule Inconn2ServiceWeb.ShiftView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.ShiftView

  def render("index.json", %{shifts: shifts}) do
    %{data: render_many(shifts, ShiftView, "shift.json")}
  end

  def render("show.json", %{shift: shift}) do
    %{data: render_one(shift, ShiftView, "shift.json")}
  end

  def render("shift.json", %{shift: shift}) do
    %{id: shift.id,
      site_id: shift.site_id,
      name: shift.name,
      start_time: shift.start_time,
      end_time: shift.end_time,
      applicable_days: shift.applicable_days,
      start_date: shift.start_date,
      end_date: shift.end_date}
  end
end
