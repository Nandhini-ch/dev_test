defmodule Inconn2ServiceWeb.LocationController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.Location

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, %{"site_id" => site_id}) do
    case Map.get(conn.query_params, "name", nil) do
      nil ->
        locations = AssetConfig.list_locations(site_id, conn.assigns.sub_domain_prefix)
        render(conn, "index.json", locations: locations)
      name ->
        locations = AssetConfig.search_locations(name, site_id, conn.assigns.sub_domain_prefix)
        render(conn, "index.json", locations: locations)
    end
  end

  def get_assets_for_location(conn, %{"location_id" => location_id}) do
    {locations, equipments} = AssetConfig.get_assets_for_location(location_id, conn.assigns.sub_domain_prefix)
    render(conn, "assets.json", locations: locations, equipments: equipments)
  end

  def display_qr_code(conn, %{"id" => id}) do
    {png, _location} = AssetConfig.get_location_qr_code(id, conn.assigns.sub_domain_prefix)
    conn
    |> put_resp_content_type("image/jpeg")
    |> send_resp(200, png)
  end

  def display_qr_code_as_pdf(conn, %{"id" => id}) do
    {name, pdf} = AssetConfig.get_location_qr_as_pdf(id, conn.assigns.sub_domain_prefix)
    conn
    |> put_resp_content_type("application/pdf")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{name}.pdf\"")
    |> send_resp(200, pdf)
  end

  def list_locations_qr(conn, %{"site_id" => site_id}) do
    locations = AssetConfig.list_locations_qr(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "asset_qrs.json", locations: locations)
  end

  def get_location_from_qr_code(conn, %{"qr_code" => qr_code}) do
    location = AssetConfig.get_location_by_qr_code(qr_code, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", location: location)
  end

  def tree(conn, %{"site_id" => site_id}) do
    locations = AssetConfig.list_locations_tree(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "tree.json", locations: locations)
  end

  def leaves(conn, %{"site_id" => site_id}) do
    locations = AssetConfig.list_locations_leaves(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", locations: locations)
  end

  def create(conn, %{"location" => location_params}) do
    with {:ok, %Location{} = location} <-
           AssetConfig.create_location(location_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.location_path(conn, :show, location))
      |> render("show.json", location: location)
    end
  end

  def show(conn, %{"id" => id}) do
    location = AssetConfig.get_location!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", location: location)
  end

  def update(conn, %{"id" => id, "location" => location_params}) do
    location = AssetConfig.get_location!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Location{} = location} <-
           AssetConfig.update_location(location, location_params, conn.assigns.sub_domain_prefix, conn.assigns.current_user) do
      render(conn, "show.json", location: location)
    end
  end

  def group_update(conn, %{"location_changes" => location_changes}) do
    update_info = AssetConfig.update_locations(location_changes, conn.assigns.sub_domain_prefix)
    render(conn, "group_update.json", update_info: update_info)
  end

  def delete(conn, %{"id" => id}) do
    location = AssetConfig.get_location!(id, conn.assigns.sub_domain_prefix)

    # <<<<<<< Updated upstream
    with {_, nil} <-
           AssetConfig.delete_location(location, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
      # =======
      case IO.inspect(AssetConfig.delete_location(location, conn.assigns.sub_domain_prefix)) do
        {:ok, %Location{}} ->
          send_resp(conn, :no_content, "")

        {_, nil} ->
          send_resp(conn, :no_content, "")
          # >>>>>>> Stashed changes
      end
    end
  end

  def activate_location(conn, %{"id" => id}) do
    location = AssetConfig.get_location!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Location{} = location} <-
           AssetConfig.update_active_status_for_location(location, %{"active" => true}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", location: location)
    end
  end

  def deactivate_location(conn, %{"id" => id}) do
    location = AssetConfig.get_location!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Location{} = location} <-
           AssetConfig.update_active_status_for_location(location, %{"active" => false}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", location: location)
    end
  end
end
