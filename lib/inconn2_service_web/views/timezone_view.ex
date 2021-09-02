defmodule Inconn2ServiceWeb.TimezoneView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.TimezoneView

  def render("index.json", %{timezones: timezones}) do
    %{data: render_many(timezones, TimezoneView, "timezone.json")}
  end

  def render("show.json", %{timezone: timezone}) do
    %{data: render_one(timezone, TimezoneView, "timezone.json")}
  end

  def render("timezone.json", %{timezone: timezone}) do
    %{id: timezone.id,
      label: timezone.label,
      zone_text: "#{timezone.label} #{timezone.utc_offset_text}"
    }
  end
end
