defmodule Inconn2Service.DashboardConfiguration do


  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.DashboardConfiguration.UserWidgetConfig


  def list_user_widget_configs(prefix) do
    Repo.all(UserWidgetConfig, prefix: prefix)
  end


  def get_user_widget_config!(id, prefix), do: Repo.get!(UserWidgetConfig, id, prefix: prefix)

  def create_user_widget_config(attrs \\ %{}, prefix) do
    %UserWidgetConfig{}
    |> UserWidgetConfig.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_user_widget_config(%UserWidgetConfig{} = user_widget_config, attrs, prefix) do
    user_widget_config
    |> UserWidgetConfig.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end


  def delete_user_widget_config(%UserWidgetConfig{} = user_widget_config, prefix) do
    Repo.delete(user_widget_config, prefix: prefix)
  end


  def change_user_widget_config(%UserWidgetConfig{} = user_widget_config, attrs \\ %{}) do
    UserWidgetConfig.changeset(user_widget_config, attrs)
  end
end
