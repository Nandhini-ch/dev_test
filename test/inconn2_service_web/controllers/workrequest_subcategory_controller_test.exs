defmodule Inconn2ServiceWeb.WorkrequestSubcategoryControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Ticket
  alias Inconn2Service.Ticket.WorkrequestSubcategory

  @create_attrs %{
    description: "some description",
    name: "some name"
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name"
  }
  @invalid_attrs %{description: nil, name: nil}

  def fixture(:workrequest_subcategory) do
    {:ok, workrequest_subcategory} = Ticket.create_workrequest_subcategory(@create_attrs)
    workrequest_subcategory
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all workrequest_subcategories", %{conn: conn} do
      conn = get(conn, Routes.workrequest_subcategory_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create workrequest_subcategory" do
    test "renders workrequest_subcategory when data is valid", %{conn: conn} do
      conn = post(conn, Routes.workrequest_subcategory_path(conn, :create), workrequest_subcategory: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.workrequest_subcategory_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.workrequest_subcategory_path(conn, :create), workrequest_subcategory: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update workrequest_subcategory" do
    setup [:create_workrequest_subcategory]

    test "renders workrequest_subcategory when data is valid", %{conn: conn, workrequest_subcategory: %WorkrequestSubcategory{id: id} = workrequest_subcategory} do
      conn = put(conn, Routes.workrequest_subcategory_path(conn, :update, workrequest_subcategory), workrequest_subcategory: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workrequest_subcategory_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, workrequest_subcategory: workrequest_subcategory} do
      conn = put(conn, Routes.workrequest_subcategory_path(conn, :update, workrequest_subcategory), workrequest_subcategory: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete workrequest_subcategory" do
    setup [:create_workrequest_subcategory]

    test "deletes chosen workrequest_subcategory", %{conn: conn, workrequest_subcategory: workrequest_subcategory} do
      conn = delete(conn, Routes.workrequest_subcategory_path(conn, :delete, workrequest_subcategory))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.workrequest_subcategory_path(conn, :show, workrequest_subcategory))
      end
    end
  end

  defp create_workrequest_subcategory(_) do
    workrequest_subcategory = fixture(:workrequest_subcategory)
    %{workrequest_subcategory: workrequest_subcategory}
  end
end
