defmodule Inconn2ServiceWeb.ServiceBranchControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.AssetInfo
  alias Inconn2Service.AssetInfo.ServiceBranch

  @create_attrs %{
    address: %{},
    contact: %{},
    region: "some region"
  }
  @update_attrs %{
    address: %{},
    contact: %{},
    region: "some updated region"
  }
  @invalid_attrs %{address: nil, contact: nil, region: nil}

  def fixture(:service_branch) do
    {:ok, service_branch} = AssetInfo.create_service_branch(@create_attrs)
    service_branch
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all service_branches", %{conn: conn} do
      conn = get(conn, Routes.service_branch_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create service_branch" do
    test "renders service_branch when data is valid", %{conn: conn} do
      conn = post(conn, Routes.service_branch_path(conn, :create), service_branch: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.service_branch_path(conn, :show, id))

      assert %{
               "id" => id,
               "address" => %{},
               "contact" => %{},
               "region" => "some region"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.service_branch_path(conn, :create), service_branch: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update service_branch" do
    setup [:create_service_branch]

    test "renders service_branch when data is valid", %{conn: conn, service_branch: %ServiceBranch{id: id} = service_branch} do
      conn = put(conn, Routes.service_branch_path(conn, :update, service_branch), service_branch: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.service_branch_path(conn, :show, id))

      assert %{
               "id" => id,
               "address" => %{},
               "contact" => %{},
               "region" => "some updated region"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, service_branch: service_branch} do
      conn = put(conn, Routes.service_branch_path(conn, :update, service_branch), service_branch: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete service_branch" do
    setup [:create_service_branch]

    test "deletes chosen service_branch", %{conn: conn, service_branch: service_branch} do
      conn = delete(conn, Routes.service_branch_path(conn, :delete, service_branch))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.service_branch_path(conn, :show, service_branch))
      end
    end
  end

  defp create_service_branch(_) do
    service_branch = fixture(:service_branch)
    %{service_branch: service_branch}
  end
end
