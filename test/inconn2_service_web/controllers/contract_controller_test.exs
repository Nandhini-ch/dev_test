defmodule Inconn2ServiceWeb.ContractControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.ContractManagement
  alias Inconn2Service.ContractManagement.Contract

  @create_attrs %{
    description: "some description",
    end_date: ~D[2010-04-17],
    name: "some name",
    start_date: ~D[2010-04-17]
  }
  @update_attrs %{
    description: "some updated description",
    end_date: ~D[2011-05-18],
    name: "some updated name",
    start_date: ~D[2011-05-18]
  }
  @invalid_attrs %{description: nil, end_date: nil, name: nil, start_date: nil}

  def fixture(:contract) do
    {:ok, contract} = ContractManagement.create_contract(@create_attrs)
    contract
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all contracts", %{conn: conn} do
      conn = get(conn, Routes.contract_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create contract" do
    test "renders contract when data is valid", %{conn: conn} do
      conn = post(conn, Routes.contract_path(conn, :create), contract: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.contract_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "end_date" => "2010-04-17",
               "name" => "some name",
               "start_date" => "2010-04-17"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.contract_path(conn, :create), contract: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update contract" do
    setup [:create_contract]

    test "renders contract when data is valid", %{conn: conn, contract: %Contract{id: id} = contract} do
      conn = put(conn, Routes.contract_path(conn, :update, contract), contract: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.contract_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "end_date" => "2011-05-18",
               "name" => "some updated name",
               "start_date" => "2011-05-18"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, contract: contract} do
      conn = put(conn, Routes.contract_path(conn, :update, contract), contract: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete contract" do
    setup [:create_contract]

    test "deletes chosen contract", %{conn: conn, contract: contract} do
      conn = delete(conn, Routes.contract_path(conn, :delete, contract))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.contract_path(conn, :show, contract))
      end
    end
  end

  defp create_contract(_) do
    contract = fixture(:contract)
    %{contract: contract}
  end
end
