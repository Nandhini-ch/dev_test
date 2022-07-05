defmodule Inconn2ServiceWeb.ConversionControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.Conversion

  @create_attrs %{
    from_unit_of_measurement_id: 42,
    multiplication_factor: 120.5,
    to_unit_of_measurement_id: 42,
    uom_category_id: 42
  }
  @update_attrs %{
    from_unit_of_measurement_id: 43,
    multiplication_factor: 456.7,
    to_unit_of_measurement_id: 43,
    uom_category_id: 43
  }
  @invalid_attrs %{from_unit_of_measurement_id: nil, multiplication_factor: nil, to_unit_of_measurement_id: nil, uom_category_id: nil}

  def fixture(:conversion) do
    {:ok, conversion} = InventoryManagement.create_conversion(@create_attrs)
    conversion
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all conversions", %{conn: conn} do
      conn = get(conn, Routes.conversion_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create conversion" do
    test "renders conversion when data is valid", %{conn: conn} do
      conn = post(conn, Routes.conversion_path(conn, :create), conversion: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.conversion_path(conn, :show, id))

      assert %{
               "id" => id,
               "from_unit_of_measurement_id" => 42,
               "multiplication_factor" => 120.5,
               "to_unit_of_measurement_id" => 42,
               "uom_category_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.conversion_path(conn, :create), conversion: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update conversion" do
    setup [:create_conversion]

    test "renders conversion when data is valid", %{conn: conn, conversion: %Conversion{id: id} = conversion} do
      conn = put(conn, Routes.conversion_path(conn, :update, conversion), conversion: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.conversion_path(conn, :show, id))

      assert %{
               "id" => id,
               "from_unit_of_measurement_id" => 43,
               "multiplication_factor" => 456.7,
               "to_unit_of_measurement_id" => 43,
               "uom_category_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, conversion: conversion} do
      conn = put(conn, Routes.conversion_path(conn, :update, conversion), conversion: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete conversion" do
    setup [:create_conversion]

    test "deletes chosen conversion", %{conn: conn, conversion: conversion} do
      conn = delete(conn, Routes.conversion_path(conn, :delete, conversion))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.conversion_path(conn, :show, conversion))
      end
    end
  end

  defp create_conversion(_) do
    conversion = fixture(:conversion)
    %{conversion: conversion}
  end
end
