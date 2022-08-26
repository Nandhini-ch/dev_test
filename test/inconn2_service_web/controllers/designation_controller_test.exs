defmodule Inconn2ServiceWeb.DesignationControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Staff
  alias Inconn2Service.Staff.Designation

  @create_attrs %{
    description: "some description",
    name: "some name"
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name"
  }
  @invalid_attrs %{description: nil, name: nil}

  def fixture(:designation) do
    {:ok, designation} = Staff.create_designation(@create_attrs)
    designation
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all designations", %{conn: conn} do
      conn = get(conn, Routes.designation_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create designation" do
    test "renders designation when data is valid", %{conn: conn} do
      conn = post(conn, Routes.designation_path(conn, :create), designation: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.designation_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.designation_path(conn, :create), designation: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update designation" do
    setup [:create_designation]

    test "renders designation when data is valid", %{conn: conn, designation: %Designation{id: id} = designation} do
      conn = put(conn, Routes.designation_path(conn, :update, designation), designation: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.designation_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, designation: designation} do
      conn = put(conn, Routes.designation_path(conn, :update, designation), designation: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete designation" do
    setup [:create_designation]

    test "deletes chosen designation", %{conn: conn, designation: designation} do
      conn = delete(conn, Routes.designation_path(conn, :delete, designation))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.designation_path(conn, :show, designation))
      end
    end
  end

  defp create_designation(_) do
    designation = fixture(:designation)
    %{designation: designation}
  end
end
