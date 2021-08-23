defmodule Inconn2ServiceWeb.HolidayControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Settings
  alias Inconn2Service.Settings.Holiday

  @create_attrs %{
    end_date: ~D[2010-04-17],
    name: "some name",
    start_date: ~D[2010-04-17]
  }
  @update_attrs %{
    end_date: ~D[2011-05-18],
    name: "some updated name",
    start_date: ~D[2011-05-18]
  }
  @invalid_attrs %{end_date: nil, name: nil, start_date: nil}

  def fixture(:holiday) do
    {:ok, holiday} = Settings.create_holiday(@create_attrs)
    holiday
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all bankholidays", %{conn: conn} do
      conn = get(conn, Routes.holiday_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create holiday" do
    test "renders holiday when data is valid", %{conn: conn} do
      conn = post(conn, Routes.holiday_path(conn, :create), holiday: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.holiday_path(conn, :show, id))

      assert %{
               "id" => id,
               "end_date" => "2010-04-17",
               "name" => "some name",
               "start_date" => "2010-04-17"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.holiday_path(conn, :create), holiday: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update holiday" do
    setup [:create_holiday]

    test "renders holiday when data is valid", %{conn: conn, holiday: %Holiday{id: id} = holiday} do
      conn = put(conn, Routes.holiday_path(conn, :update, holiday), holiday: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.holiday_path(conn, :show, id))

      assert %{
               "id" => id,
               "end_date" => "2011-05-18",
               "name" => "some updated name",
               "start_date" => "2011-05-18"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, holiday: holiday} do
      conn = put(conn, Routes.holiday_path(conn, :update, holiday), holiday: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete holiday" do
    setup [:create_holiday]

    test "deletes chosen holiday", %{conn: conn, holiday: holiday} do
      conn = delete(conn, Routes.holiday_path(conn, :delete, holiday))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.holiday_path(conn, :show, holiday))
      end
    end
  end

  defp create_holiday(_) do
    holiday = fixture(:holiday)
    %{holiday: holiday}
  end
end
