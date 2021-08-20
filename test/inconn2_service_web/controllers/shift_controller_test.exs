defmodule Inconn2ServiceWeb.ShiftControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Settings
  alias Inconn2Service.Settings.Shift

  @create_attrs %{
    applicable_days: [],
    end_date: ~D[2010-04-17],
    end_time: ~T[14:00:00],
    name: "some name",
    start_date: ~D[2010-04-17],
    start_time: ~T[14:00:00]
  }
  @update_attrs %{
    applicable_days: [],
    end_date: ~D[2011-05-18],
    end_time: ~T[15:01:01],
    name: "some updated name",
    start_date: ~D[2011-05-18],
    start_time: ~T[15:01:01]
  }
  @invalid_attrs %{applicable_days: nil, end_date: nil, end_time: nil, name: nil, start_date: nil, start_time: nil}

  def fixture(:shift) do
    {:ok, shift} = Settings.create_shift(@create_attrs)
    shift
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all shifts", %{conn: conn} do
      conn = get(conn, Routes.shift_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create shift" do
    test "renders shift when data is valid", %{conn: conn} do
      conn = post(conn, Routes.shift_path(conn, :create), shift: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.shift_path(conn, :show, id))

      assert %{
               "id" => id,
               "applicable_days" => [],
               "end_date" => "2010-04-17",
               "end_time" => "14:00:00",
               "name" => "some name",
               "start_date" => "2010-04-17",
               "start_time" => "14:00:00"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.shift_path(conn, :create), shift: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update shift" do
    setup [:create_shift]

    test "renders shift when data is valid", %{conn: conn, shift: %Shift{id: id} = shift} do
      conn = put(conn, Routes.shift_path(conn, :update, shift), shift: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.shift_path(conn, :show, id))

      assert %{
               "id" => id,
               "applicable_days" => [],
               "end_date" => "2011-05-18",
               "end_time" => "15:01:01",
               "name" => "some updated name",
               "start_date" => "2011-05-18",
               "start_time" => "15:01:01"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, shift: shift} do
      conn = put(conn, Routes.shift_path(conn, :update, shift), shift: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete shift" do
    setup [:create_shift]

    test "deletes chosen shift", %{conn: conn, shift: shift} do
      conn = delete(conn, Routes.shift_path(conn, :delete, shift))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.shift_path(conn, :show, shift))
      end
    end
  end

  defp create_shift(_) do
    shift = fixture(:shift)
    %{shift: shift}
  end
end
