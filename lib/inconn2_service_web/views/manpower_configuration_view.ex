defmodule Inconn2ServiceWeb.ManpowerConfigurationView do
  use Inconn2ServiceWeb, :view
  alias Inconn2ServiceWeb.ManpowerConfigurationView

  def render("index.json", %{manpower_configurations: manpower_configurations}) do
    %{data: render_many(manpower_configurations, ManpowerConfigurationView, "manpower_configuration.json")}
  end

  def render("show.json", %{manpower_configuration: manpower_configuration}) do
    %{data: render_one(manpower_configuration, ManpowerConfigurationView, "manpower_configuration.json")}
  end

  def render("manpower_configuration.json", %{manpower_configuration: manpower_configuration}) do
    %{id: manpower_configuration.id,
      # site_id: manpower_configuration.site_id,
      site: %{
        id: manpower_configuration.site.id,
        name: manpower_configuration.site.name
      },
      designation: %{
        id: manpower_configuration.designation_id,
        name: manpower_configuration.designation.name
      },
      shift: %{
        id: manpower_configuration.shift_id,
        name: manpower_configuration.shift.name,
        code: manpower_configuration.shift.code
      },
      quantity: manpower_configuration.quantity,
      contract_id: manpower_configuration.contract_id}
  end
end
