defmodule Inconn2ServiceWeb.WorkorderFileUploadControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Workorder
  alias Inconn2Service.Workorder.WorkorderFileUpload

  @create_attrs %{
    file: "some file",
    file_type: "some file_type",
    workorder_task_id: 42
  }
  @update_attrs %{
    file: "some updated file",
    file_type: "some updated file_type",
    workorder_task_id: 43
  }
  @invalid_attrs %{file: nil, file_type: nil, workorder_task_id: nil}

  def fixture(:workorder_file_upload) do
    {:ok, workorder_file_upload} = Workorder.create_workorder_file_upload(@create_attrs)
    workorder_file_upload
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all workorder_file_uploads", %{conn: conn} do
      conn = get(conn, Routes.workorder_file_upload_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create workorder_file_upload" do
    test "renders workorder_file_upload when data is valid", %{conn: conn} do
      conn = post(conn, Routes.workorder_file_upload_path(conn, :create), workorder_file_upload: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.workorder_file_upload_path(conn, :show, id))

      assert %{
               "id" => id,
               "file" => "some file",
               "file_type" => "some file_type",
               "workorder_task_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.workorder_file_upload_path(conn, :create), workorder_file_upload: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update workorder_file_upload" do
    setup [:create_workorder_file_upload]

    test "renders workorder_file_upload when data is valid", %{conn: conn, workorder_file_upload: %WorkorderFileUpload{id: id} = workorder_file_upload} do
      conn = put(conn, Routes.workorder_file_upload_path(conn, :update, workorder_file_upload), workorder_file_upload: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.workorder_file_upload_path(conn, :show, id))

      assert %{
               "id" => id,
               "file" => "some updated file",
               "file_type" => "some updated file_type",
               "workorder_task_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, workorder_file_upload: workorder_file_upload} do
      conn = put(conn, Routes.workorder_file_upload_path(conn, :update, workorder_file_upload), workorder_file_upload: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete workorder_file_upload" do
    setup [:create_workorder_file_upload]

    test "deletes chosen workorder_file_upload", %{conn: conn, workorder_file_upload: workorder_file_upload} do
      conn = delete(conn, Routes.workorder_file_upload_path(conn, :delete, workorder_file_upload))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.workorder_file_upload_path(conn, :show, workorder_file_upload))
      end
    end
  end

  defp create_workorder_file_upload(_) do
    workorder_file_upload = fixture(:workorder_file_upload)
    %{workorder_file_upload: workorder_file_upload}
  end
end
