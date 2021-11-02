defmodule Inconn2ServiceWeb.FeatureController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Staff
  #alias Inconn2Service.Staff.Feature

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    case Map.get(conn.query_params, "name", nil) do
      nil ->
        features = Staff.list_features(conn.assigns.sub_domain_prefix)
        render(conn, "index.json", features: features)
      name ->
        features = Staff.search_features(name, conn.assigns.sub_domain_prefix)
        render(conn, "index.json", features: features)
    end
  end

  # def create(conn, %{"feature" => feature_params}) do
  #   with {:ok, %Feature{} = feature} <- Staff.create_feature(feature_params, conn.assigns.sub_domain_prefix) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", Routes.feature_path(conn, :show, feature))
  #     |> render("show.json", feature: feature)
  #   end
  # end
  #
  # def show(conn, %{"id" => id}) do
  #   feature = Staff.get_feature!(id, conn.assigns.sub_domain_prefix)
  #   render(conn, "show.json", feature: feature)
  # end
  #
  # def update(conn, %{"id" => id, "feature" => feature_params}) do
  #   feature = Staff.get_feature!(id, conn.assigns.sub_domain_prefix)
  #
  #   with {:ok, %Feature{} = feature} <- Staff.update_feature(feature, feature_params, conn.assigns.sub_domain_prefix) do
  #     render(conn, "show.json", feature: feature)
  #   end
  # end
  #
  # def delete(conn, %{"id" => id}) do
  #   feature = Staff.get_feature!(id, conn.assigns.sub_domain_prefix)
  #
  #   with {:ok, %Feature{}} <- Staff.delete_feature(feature, conn.assigns.sub_domain_prefix) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
