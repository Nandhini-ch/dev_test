defmodule Inconn2Service.DashboardConfiguration do

  import Ecto.Query, warn: false
  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Repo
  alias Inconn2Service.Common

  alias Inconn2Service.DashboardConfiguration.UserWidgetConfig

  def list_user_widget_configs(user_id, prefix) do
    from(uwc in UserWidgetConfig, where: uwc.user_id == ^user_id)
    |> Repo.all(prefix: prefix)
    |> preload_widgets()
  end

  def get_widget_config_by_code_and_user(widget_code, user_id, prefix) do
    from(uwc in UserWidgetConfig, where: uwc.user_id == ^user_id and uwc.widget_code == ^widget_code)
    |> Repo.one(prefix: prefix)
  end

  def get_user_widget_config!(id, prefix), do: Repo.get!(UserWidgetConfig, id, prefix: prefix)

  def create_or_update_configs(attrs_list \\ [], user, prefix) do
    result = create_or_update_multiple_widget_configs(attrs_list, user, prefix)

    failures = get_success_or_failure_list(result, :error)
    case length(failures) do
      0 ->
        {:ok,
        get_success_or_failure_list(result, :ok) |> preload_widgets()}

      _ ->
        {:multiple_error, failures}
    end
  end

  def create_or_update_multiple_widget_configs(attrs_list, user, prefix) do
    Enum.map(attrs_list, fn attrs ->
      if is_nil(attrs["user_id"]) do
        create_or_update_individual_widget_config(Map.put(attrs, "user_id", user.id), prefix)
      else
        create_or_update_individual_widget_config(attrs, prefix)
      end
    end)
  end

  def create_or_update_individual_widget_config(attrs, prefix) do
    widget_config = get_widget_config_by_code_and_user(attrs["widget_code"], attrs["user_id"], prefix)
    case widget_config do
      nil -> create_user_widget_config(attrs, prefix)
      _ -> update_user_widget_config(widget_config, attrs, prefix)
    end
  end

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

  def delete_user_widget_configs(delete_list, user, prefix) do
    Enum.map(delete_list, fn delete_map ->
        get_widget_config_by_code_and_user(
          delete_map["widget_code"],
          get_user_from_map(delete_map, user),
          prefix)
        |> Repo.delete(prefix: prefix)
    end)
  end

  def delete_user_widget_config(user_widget_config, prefix) do
    Repo.delete(user_widget_config, prefix: prefix)
  end

  def change_user_widget_config(%UserWidgetConfig{} = user_widget_config, attrs \\ %{}) do
    UserWidgetConfig.changeset(user_widget_config, attrs)
  end

  defp get_user_from_map(map, user) do
    if is_nil(map["user_id"]) do
      user.id
    else
      map["user_id"]
    end
  end

  defp preload_widgets(user_widget_list) when is_list(user_widget_list) do
    Enum.map(user_widget_list, fn uwc -> Map.put(uwc, :widget, Common.get_widget_by_code(uwc.widget_code)) end)
  end
end
