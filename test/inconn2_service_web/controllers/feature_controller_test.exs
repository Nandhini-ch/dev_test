defmodule Inconn2ServiceWeb.FeatureControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.Staff
  alias Inconn2Service.Staff.Feature

  @create_attrs %{
    code: "some code",
    description: "some description",
    name: "some name"
  }
  @update_attrs %{
    code: "some updated code",
    description: "some updated description",
    name: "some updated name"
  }
  @invalid_attrs %{code: nil, description: nil, name: nil}

  def fixture(:feature) do
    {:ok, feature} = Staff.create_feature(@create_attrs)
    feature
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all features", %{conn: conn} do
      conn = get(conn, Routes.feature_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create feature" do
    test "renders feature when data is valid", %{conn: conn} do
      conn = post(conn, Routes.feature_path(conn, :create), feature: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.feature_path(conn, :show, id))

      assert %{
               "id" => id,
               "code" => "some code",
               "description" => "some description",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.feature_path(conn, :create), feature: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update feature" do
    setup [:create_feature]

    test "renders feature when data is valid", %{conn: conn, feature: %Feature{id: id} = feature} do
      conn = put(conn, Routes.feature_path(conn, :update, feature), feature: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.feature_path(conn, :show, id))

      assert %{
               "id" => id,
               "code" => "some updated code",
               "description" => "some updated description",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, feature: feature} do
      conn = put(conn, Routes.feature_path(conn, :update, feature), feature: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete feature" do
    setup [:create_feature]

    test "deletes chosen feature", %{conn: conn, feature: feature} do
      conn = delete(conn, Routes.feature_path(conn, :delete, feature))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.feature_path(conn, :show, feature))
      end
    end
  end

  defp create_feature(_) do
    feature = fixture(:feature)
    %{feature: feature}
  end
end
