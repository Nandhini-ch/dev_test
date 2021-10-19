defmodule Inconn2Service.Repo do
  use Ecto.Repo,
    otp_app: :inconn2_service,
    adapter: Ecto.Adapters.Postgres

  def add_active_filter(query, query_params) do
    filler =
      case query_params do
        %{"active" => "true"} -> %{active: true}
        %{"active" => "false"} -> %{active: false}
        _ -> %{}
      end

      case Map.get(filter, active: true) do
        true -> where(query, active: true)
        false -> where(query, active: false)
        _ -> query
    end
  end
end
