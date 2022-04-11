defmodule Inconn2Service.Release do
  alias Inconn2Service.Account
  alias Ecto.Migrator
  @app :inconn2_service

  def migrate do
    {:ok, _} = Application.ensure_all_started(@app)

    migrate_public_schema()
    # create_time_zones()
    create_alert_notification_reserve()
    migrate_tenant_schemas()
  end


  defp migrate_public_schema do
    path = Application.app_dir(@app, "priv/repo/migrations")
    Migrator.run(Inconn2Service.Repo, path, :up, all: true)
  end

  defp migrate_tenant_schemas do
    path = Application.app_dir(@app, "priv/repo/tenant_migrations")

    Account.list_licensees()
    |> Enum.map(fn licensee -> Map.put_new(licensee, :prefix, "inc_" <> licensee.sub_domain) end)
    |> Enum.each(&Migrator.run(Inconn2Service.Repo, path, :up, all: true, prefix: &1.prefix))
  end

  defp create_time_zones do
    path = Application.app_dir(@app, "priv/repo/timezones")
    Migrator.run(Inconn2Service.Repo, path, :up, all: true)
  end

  defp create_alert_notification_reserve do
    path = Application.app_dir(@app, "priv/repo/alerts_and_notifications")
    Migrator.run(Inconn2Service.Repo, path, :up, all: true)
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
