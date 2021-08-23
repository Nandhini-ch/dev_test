defmodule Inconn2ServiceWeb.HolidayController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Settings
  alias Inconn2Service.Settings.Holiday

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, _params, %{"year" => year, "site_id" => site_id}) do
    {:ok, year_begin} = year_end_date_convert(year)
    {:ok, year_end} = year_start_date_convert(year)

    bankholidays =
      Settings.list_bankholidays(site_id, year_begin, year_end, conn.assigns.sub_domain_prefix)

    render(conn, "index.json", bankholidays: bankholidays)
  end

  def create(conn, %{"holiday" => holiday_params}) do
    with {:ok, %Holiday{} = holiday} <-
           Settings.create_holiday(holiday_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.holiday_path(conn, :show, holiday))
      |> render("show.json", holiday: holiday)
    end
  end

  def show(conn, %{"id" => id}) do
    holiday = Settings.get_holiday!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", holiday: holiday)
  end

  @spec update(
          atom
          | %{
              :assigns => atom | %{:sub_domain_prefix => any, optional(any) => any},
              optional(any) => any
            },
          map
        ) :: any
  def update(conn, %{"id" => id, "holiday" => holiday_params}) do
    holiday = Settings.get_holiday!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Holiday{} = holiday} <-
           Settings.update_holiday(holiday, holiday_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", holiday: holiday)
    end
  end

  def delete(conn, %{"id" => id}) do
    holiday = Settings.get_holiday!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Holiday{}} <- Settings.delete_holiday(holiday, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

  defp year_end_date_convert(year) do
    Date.new(year, 12, 31)
  end

  defp year_start_date_convert(year) do
    Date.new(year, 01, 01)
  end
end
