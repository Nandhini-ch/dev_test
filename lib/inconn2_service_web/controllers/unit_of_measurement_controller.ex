defmodule Inconn2ServiceWeb.UnitOfMeasurementController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.UnitOfMeasurement

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    unit_of_measurements = InventoryManagement.list_unit_of_measurements(conn.query_params, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", unit_of_measurements: unit_of_measurements)
  end

  def index_by_uom_category(conn, %{"uom_category_id" => uom_category_id}) do
    unit_of_measurements = InventoryManagement.list_unit_of_measurements_by_uom_category(uom_category_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", unit_of_measurements: unit_of_measurements)
  end

  def create(conn, %{"unit_of_measurement" => unit_of_measurement_params}) do
    with {:ok, %UnitOfMeasurement{} = unit_of_measurement} <- InventoryManagement.create_unit_of_measurement(unit_of_measurement_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.unit_of_measurement_path(conn, :show, unit_of_measurement))
      |> render("show.json", unit_of_measurement: unit_of_measurement)
    end
  end

  def show(conn, %{"id" => id}) do
    unit_of_measurement = InventoryManagement.get_unit_of_measurement!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", unit_of_measurement: unit_of_measurement)
  end

  def update(conn, %{"id" => id, "unit_of_measurement" => unit_of_measurement_params}) do
    unit_of_measurement = InventoryManagement.get_unit_of_measurement!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %UnitOfMeasurement{} = unit_of_measurement} <- InventoryManagement.update_unit_of_measurement(unit_of_measurement, unit_of_measurement_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", unit_of_measurement: unit_of_measurement)
    end
  end

  def update_multiple(conn, %{"unit_iof_measurement_changes" => unit_of_measurement_changes}) do
    unit_of_measurements = InventoryManagement.update_unit_of_measurements(unit_of_measurement_changes, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", unit_of_measurements: unit_of_measurements)
  end

  def delete(conn, %{"id" => id}) do
    unit_of_measurement = InventoryManagement.get_unit_of_measurement!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %UnitOfMeasurement{}} <- InventoryManagement.delete_unit_of_measurement(unit_of_measurement, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
