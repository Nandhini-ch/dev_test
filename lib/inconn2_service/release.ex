defmodule Inconn2Service.Release do
  alias Inconn2Service.Account
  @app :inconn2_service

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def migrate_tenant_schemas do
    load_app()

    path = Application.app_dir(:inconn2_service, "priv/repo/tenant_migrations")
    for repo <- repos() do
      Account.list_licensees()
      |> Enum.each(&Ecto.Migrator.run(repo, path, :up, all: true, prefix: &1.prefix))
    end


  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
