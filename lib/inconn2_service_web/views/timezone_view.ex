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
      #zone_text: label utcoffeset text
      continent: timezone.continent,
      state: timezone.state,
      city: timezone.city,
      city_low: timezone.city_low,
      city_stripped: timezone.city_stripped,
      utc_offset_text: timezone.utc_offset_text,
      utc_offset_seconds: timezone.utc_offset_seconds}
  end
end
