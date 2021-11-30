defmodule Inconn2ServiceWeb.ShiftController do
  use Inconn2ServiceWeb, :controller

  alias Inconn2Service.Settings
  alias Inconn2Service.Settings.Shift

  action_fallback Inconn2ServiceWeb.FallbackController

  def index(conn, %{
        "site_id" => site_id,
        "start_date_shift" => start_date_shift,
        "end_date_shift" => end_date_shift
      }) do
    # expecting date in dd/mm/yyyy - can write more generic ones later
    # date_for_shift_list = date_for_shift |> String.split("/")
    {:ok, start_date_for_shift} = date_convert(start_date_shift)
    IO.inspect(start_date_for_shift)
    {:ok, end_date_for_shift} = date_convert(end_date_shift)
    IO.inspect(end_date_for_shift)

    shifts =
      Settings.list_shifts_between_dates(
        site_id,
        start_date_for_shift,
        end_date_for_shift,
        conn.assigns.sub_domain_prefix
      )

    render(conn, "index.json", shifts: shifts)
  end

  def index(conn, %{"site_id" => site_id, "date_for_shift" => date_for_shift}) do
    # expecting date in dd/mm/yyyy - can write more generic ones later
    {:ok, date_for_shift_query} = date_convert(date_for_shift)

    # date_for_shift_list = date_for_shift |> String.split("/")
    IO.inspect(date_for_shift_query)

    shifts =
      Settings.list_shifts_for_a_day(
        site_id,
        date_for_shift_query,
        conn.assigns.sub_domain_prefix
      )

    render(conn, "index.json", shifts: shifts)
  end

  def index(conn, %{"site_id" => site_id}) do
    shifts = Settings.list_shifts(site_id, conn.assigns.sub_domain_prefix)
    render(conn, "index.json", shifts: shifts)
  end

  def create(conn, %{"shift" => shift_params}) do
    with {:ok, %Shift{} = shift} <-
           Settings.create_shift(shift_params, conn.assigns.sub_domain_prefix) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.shift_path(conn, :show, shift))
      |> render("show.json", shift: shift)
    end
  end

  def show(conn, %{"id" => id}) do
    shift = Settings.get_shift!(id, conn.assigns.sub_domain_prefix)
    render(conn, "show.json", shift: shift)
  end

  def update(conn, %{"id" => id, "shift" => shift_params}) do
    shift = Settings.get_shift!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Shift{} = shift} <-
           Settings.update_shift(shift, shift_params, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", shift: shift)
    end
  end

  def delete(conn, %{"id" => id}) do
    shift = Settings.get_shift!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Shift{}} <- Settings.delete_shift(shift, conn.assigns.sub_domain_prefix) do
      send_resp(conn, :no_content, "")
    end
  end

  def activate_shift(conn, %{"id" => id}) do
    shift = Settings.get_shift!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Shift{} = shift} <-
           Settings.update_active_status_for_shift(shift, %{"active" => true}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", shift: shift)
    end
  end

  def deactivate_shift(conn, %{"id" => id}) do
    shift = Settings.get_shift!(id, conn.assigns.sub_domain_prefix)

    with {:ok, %Shift{} = shift} <-
           Settings.update_active_status_for_shift(shift, %{"active" => false}, conn.assigns.sub_domain_prefix) do
      render(conn, "show.json", shift: shift)
    end
  end

  defp date_convert(date_to_convert) do
    date_to_convert
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
    |> (fn [year, month, day] -> Date.new(year, month, day) end).()
  end
end
