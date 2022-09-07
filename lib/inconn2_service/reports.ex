defmodule Inconn2Service.Reports do

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Reports.MyReport


  def list_my_reports(prefix, user) do
    from(mr in MyReport, where: mr.user_id == ^user.id)
    |> Repo.all(prefix: prefix)
  end

  def get_my_report!(id, prefix), do: Repo.get!(MyReport, id, prefix: prefix)

  def create_my_report(attrs \\ %{}, user, prefix) do
    attrs = Map.put(attrs, "user_id", user.id)
    %MyReport{}
    |> MyReport.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end


  def update_my_report(%MyReport{} = my_report, attrs, prefix) do
    my_report
    |> MyReport.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  def delete_my_report(%MyReport{} = my_report, prefix) do
    Repo.delete(my_report, prefix: prefix)
  end

  def change_my_report(%MyReport{} = my_report, attrs \\ %{}) do
    MyReport.changeset(my_report, attrs)
  end
end
