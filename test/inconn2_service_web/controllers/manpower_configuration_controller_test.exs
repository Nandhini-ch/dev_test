defmodule Inconn2ServiceWeb.ManpowerConfigurationControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.ContractManagement
  alias Inconn2Service.ContractManagement.ManpowerConfiguration

  @create_attrs %{
    designation_id: 42,
    quantity: 42,
    shift_id: 42,
    site_id: 42
  }
  @update_attrs %{
    designation_id: 43,
    quantity: 43,
    shift_id: 43,
    site_id: 43
  }
  @invalid_attrs %{designation_id: nil, quantity: nil, shift_id: nil, site_id: nil}

  def fixture(:manpower_configuration) do
    {:ok, manpower_configuration} = ContractManagement.create_manpower_configuration(@create_attrs)
    manpower_configuration
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all manpower_configurations", %{conn: conn} do
      conn = get(conn, Routes.manpower_configuration_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create manpower_configuration" do
    test "renders manpower_configuration when data is valid", %{conn: conn} do
      conn = post(conn, Routes.manpower_configuration_path(conn, :create), manpower_configuration: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.manpower_configuration_path(conn, :show, id))

      assert %{
               "id" => id,
               "designation_id" => 42,
               "quantity" => 42,
               "shift_id" => 42,
               "site_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.manpower_configuration_path(conn, :create), manpower_configuration: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update manpower_configuration" do
    setup [:create_manpower_configuration]

    test "renders manpower_configuration when data is valid", %{conn: conn, manpower_configuration: %ManpowerConfiguration{id: id} = manpower_configuration} do
      conn = put(conn, Routes.manpower_configuration_path(conn, :update, manpower_configuration), manpower_configuration: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.manpower_configuration_path(conn, :show, id))

      assert %{
               "id" => id,
               "designation_id" => 43,
               "quantity" => 43,
               "shift_id" => 43,
               "site_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, manpower_configuration: manpower_configuration} do
      conn = put(conn, Routes.manpower_configuration_path(conn, :update, manpower_configuration), manpower_configuration: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete manpower_configuration" do
    setup [:create_manpower_configuration]

    test "deletes chosen manpower_configuration", %{conn: conn, manpower_configuration: manpower_configuration} do
      conn = delete(conn, Routes.manpower_configuration_path(conn, :delete, manpower_configuration))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.manpower_configuration_path(conn, :show, manpower_configuration))
      end
    end
  end

  defp create_manpower_configuration(_) do
    manpower_configuration = fixture(:manpower_configuration)
    %{manpower_configuration: manpower_configuration}
  end
end
