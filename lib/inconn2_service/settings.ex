defmodule Inconn2Service.Settings do
  @moduledoc """
  The Settings context.
  """

  import Ecto.Query, warn: false
  import Inconn2Service.Util.DeleteManager
  import Inconn2Service.Prompt
  # import Inconn2Service.Util.IndexQueries
  # import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Repo

  alias Inconn2Service.Settings.Shift


  def list_shifts(prefix) do
    Shift
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end

  def list_shift_ids(site_id, prefix) do
    from(sh in Shift, where: sh.site_id == ^site_id and sh.active, select: sh.id)
    |> Repo.all(prefix: prefix)
  end

  def list_shifts(site_id, prefix) do
    Shift
    |> where(site_id: ^site_id)
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end

  def list_shifts(site_id, _query_params, prefix) do
    Shift
    |> Repo.add_active_filter()
    |> where(site_id: ^site_id)
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end

  def list_shifts_for_a_day(site_id, shiftdate, prefix) do
    day = Date.day_of_week(shiftdate)
    query =
      from(s in Shift,
        where:
          s.site_id == ^site_id and
          fragment("? BETWEEN ? AND ?", ^shiftdate, s.start_date, s.end_date) and
          ^day in s.applicable_days
      )

    IO.inspect(query)
    Repo.add_active_filter(query)
    |> Repo.all(prefix: prefix)
  end
  def list_shifts_between_dates(site_id, start_shiftdate, end_shiftdate, prefix) do
    # constructing a query like below
    # SELECT s0."id", s0."applicable_days", s0."end_date",
    # s0."end_time", s0."name", s0."start_date", s0."start_time",
    # s0."site_id", s0."inserted_at", s0."updated_at"
    # FROM "inc_bata"."shifts" AS s0
    # WHERE ((s0."site_id" = 1) AND '2021-08-19' >= s0."start_date"
    # AND '2021-08-21'  >= s0."start_date" OR s0."end_date" >= '2021-08-19'
    # AND s0."end_date" <= '2021-08-21')

    query =
      from(s in Shift,
        where:
          s.site_id == ^site_id and
            fragment(
              "(? >= ? AND ?  >= ?) OR (? >= ? AND ? <= ? )",
              ^start_shiftdate,
              s.start_date,
              ^end_shiftdate,
              s.start_date,
              s.end_date,
              ^start_shiftdate,
              s.end_date,
              ^end_shiftdate
            )
      )

    IO.inspect(query)
    Repo.add_active_filter(query)
    |> Repo.all(prefix: prefix)
    |> Repo.sort_by_id()
  end


  def get_shifts_by_ids(ids, prefix) do
    from(sh in Shift, where: sh.id in ^ids)
    |> Repo.all(prefix: prefix)
  end

  def get_shift!(id, prefix), do: Repo.get!(Shift, id, prefix: prefix)
  def get_shift(id, prefix), do: Repo.get(Shift, id, prefix: prefix)

  def create_shift(attrs \\ %{}, prefix) do
    %Shift{}
    |> Shift.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_shift(%Shift{} = shift, attrs, prefix) do
    shift
    |> Shift.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_shift(%Shift{} = shift, prefix) do
    cond do
      has_employee_rosters?(shift, prefix) ->
        {:could_not_delete,
        "Cannot be deleted as there are Roster associated with it"
        }

      has_manpower_configuration?(shift, prefix) ->
        {:could_not_delete,
          "Cannot be deleted as there are Manpower configuration associated with it"
        }

      true ->
        update_shift(shift, %{"active" => false}, prefix)
           {:deleted,
              "The Shift was disabled"
           }
    end
  end


  def change_shift(%Shift{} = shift, attrs \\ %{}) do
    Shift.changeset(shift, attrs)
  end

  alias Inconn2Service.Settings.Holiday

  def list_bankholidays(prefix) do
    Holiday
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
  end

  def list_bankholidays(_query_params, prefix) do
    Holiday
    |> Repo.add_active_filter()
    |> Repo.all(prefix: prefix)
  end

  def list_bankholidays(site_id, year_begin, year_end, prefix) do
    query =
      from(h in Holiday,
        where:
          h.site_id == ^site_id and
            fragment(
              "(? >=? AND ? <= ?)",
              h.start_date,
              ^year_begin,
              h.end_date,
              ^year_end
            )
      )

    IO.inspect(query)
    Repo.add_active_filter(query)
    |> Repo.all(prefix: prefix)
  end


  def get_holiday!(id, prefix), do: Repo.get!(Holiday, id, prefix: prefix)


  def create_holiday(attrs \\ %{}, prefix) do
    %Holiday{}
    |> Holiday.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end


  def update_holiday(%Holiday{} = holiday, attrs, prefix) do
    holiday
    |> Holiday.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end


  def delete_holiday(%Holiday{} = holiday, prefix) do
    update_holiday(holiday, %{"active" => false}, prefix)
       {:deleted,
         "The holiday was disabled"
       }
  end

  def change_holiday(%Holiday{} = holiday, attrs \\ %{}) do
    Holiday.changeset(holiday, attrs)
  end

  # def push_alert_notification_for_new_shift(site_id, prefix) do
  #   generate_alert_notification("NSHAD", site_id, ["site_name"], [], [], prefix)
  # end
end

