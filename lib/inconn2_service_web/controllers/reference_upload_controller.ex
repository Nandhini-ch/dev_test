defmodule Inconn2ServiceWeb.ReferenceUploadController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.ReferenceDataUploader
  action_fallback Inconn2ServiceWeb.FallbackController

  def upload_locations(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_locations(file, conn.assigns.sub_domain_prefix)

    case data do
      {:error, error_data} ->
        if error_data == ["Invalid Header Fields"] do
          render(conn, "invalid.json", %{})
        else
          render(conn, "failure.json", failed_data: error_data)
        end

      _ ->
        render(conn, "success.json", %{})
    end
  end

  def upload_equipments(conn, params) do
    file = params["csv_file"]
    data = ReferenceDataUploader.upload_equipments(file, conn.assigns.sub_domain_prefix)

    case data do
      {:error, error_data} ->
        if error_data == ["Invalid Header Fields"] do
          render(conn, "invalid.json", %{})
        else
          render(conn, "failure.json", failed_data: error_data)
        end

      _ ->
        render(conn, "success.json", %{})
    end
  end

end
