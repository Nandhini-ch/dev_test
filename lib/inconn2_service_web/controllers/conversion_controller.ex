defmodule Inconn2ServiceWeb.ConversionController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.InventoryManagement
  alias Inconn2Service.InventoryManagement.Conversion

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params) do
    conversions = InventoryManagement.list_conversions(conn.assigns.sub_domain_prefix)
    render(conn, "index.json", conversions: conversions)
  end

  def create(conn, %{"conversion" => conversion_params}) do
    with {:ok, %Conversion{} = conversion} <- InventoryManagement.create_conversion(conversion_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.conversion_path(conn, :show, conversion))
      |> render("show.json", conversion: conversion)
    end
  end

  def show(conn, %{"id" => id}) do
    conversion = InventoryManagement.get_conversion!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", conversion: conversion)
  end

  def update(conn, %{"id" => id, "conversion" => conversion_params}) do
    conversion = InventoryManagement.get_conversion!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Conversion{} = conversion} <- InventoryManagement.update_conversion(conversion, conversion_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", conversion: conversion)
    end
  end

  def delete(conn, %{"id" => id}) do
    conversion = InventoryManagement.get_conversion!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Conversion{}} <- InventoryManagement.delete_conversion(conversion, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end
end
