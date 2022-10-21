defmodule Inconn2Service.Repo do
  use Ecto.Repo,
    otp_app: :inconn2_service,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query, warn: false

  def add_active_filter(query), do: from q in query, where: q.active

  def sort_by_id(list), do: Enum.sort_by(list, &(&1.id), :asc)
end
