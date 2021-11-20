defmodule Inconn2ServiceWeb.ModuleController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Staff
  #alias Inconn2Service.Staff.Module

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    modules = Staff.list_modules(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", modules: modules)
  end

  # def create(conn, %{"module" => module_params}) do
  #   with {:ok, %Module{} = module} <- Staff.create_module(module_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", Routes.module_path(conn, :show, module))
  #     |> render("show.json", module: module)
  #   end
  # end

  def show(conn, %{"id" => id}) do
    module = Staff.get_module!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", module: module)
  end

  # def update(conn, %{"id" => id, "module" => module_params}) do
  #   module = Staff.get_module!(id)
  #
  #   with {:ok, %Module{} = module} <- Staff.update_module(module, module_params) do
  #     render(conn, "show.json", module: module)
  #   end
  # end
  #
  # def delete(conn, %{"id" => id}) do
  #   module = Staff.get_module!(id)
  #
  #   with {:ok, %Module{}} <- Staff.delete_module(module) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
