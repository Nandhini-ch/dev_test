defmodule Inconn2ServiceWeb.MyReportControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Reports
  alias Inconn2Service.Reports.MyReport

  @create_attrs %{
    code: "some code",
    description: "some description",
    name: "some name",
    report_params: %{}
  }
  @update_attrs %{
    code: "some updated code",
    description: "some updated description",
    name: "some updated name",
    report_params: %{}
  }
  @invalid_attrs %{code: nil, description: nil, name: nil, report_params: nil}

  def fixture(:my_report) do
    {:ok, my_report} = Reports.create_my_report(@create_attrs)
    my_report
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all my_reports", %{conn: conn} do
      conn = get(conn, Routes.my_report_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create my_report" do
    test "renders my_report when data is valid", %{conn: conn} do
      conn = post(conn, Routes.my_report_path(conn, :create), my_report: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.my_report_path(conn, :show, id))

      assert %{
               "id" => id,
               "code" => "some code",
               "description" => "some description",
               "name" => "some name",
               "report_params" => %{}
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.my_report_path(conn, :create), my_report: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update my_report" do
    setup [:create_my_report]

    test "renders my_report when data is valid", %{conn: conn, my_report: %MyReport{id: id} = my_report} do
      conn = put(conn, Routes.my_report_path(conn, :update, my_report), my_report: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.my_report_path(conn, :show, id))

      assert %{
               "id" => id,
               "code" => "some updated code",
               "description" => "some updated description",
               "name" => "some updated name",
               "report_params" => %{}
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, my_report: my_report} do
      conn = put(conn, Routes.my_report_path(conn, :update, my_report), my_report: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete my_report" do
    setup [:create_my_report]

    test "deletes chosen my_report", %{conn: conn, my_report: my_report} do
      conn = delete(conn, Routes.my_report_path(conn, :delete, my_report))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.my_report_path(conn, :show, my_report))
      end
    end
  end

  defp create_my_report(_) do
    my_report = fixture(:my_report)
    %{my_report: my_report}
  end
end
