defmodule Inconn2Service.DashboardConfiguration do

  import Ecto.Changeset
  import Ecto.Query, warn: false
  import Inconn2Service.Util.HelpersFunctions
  alias Inconn2Service.Repo
  alias Inconn2Service.Common

  alias Inconn2Service.DashboardConfiguration.UserWidgetConfig

  def list_user_widget_configs(params, user, prefix) do
    user_id = get_user_from_map(params, user)
    list_user_widget_configs_for_user(user_id, params["device"], prefix)
  end

  def list_user_widget_configs_for_user(user_id, device, prefix) do
    from(uwc in UserWidgetConfig, where: uwc.user_id == ^user_id and uwc.device == ^device)
    |> Repo.all(prefix: prefix)
    |> preload_widgets()
  end

  def get_widget_config_by_code_and_user_and_device(widget_code, user_id, device, prefix) do
    from(uwc in UserWidgetConfig, where: uwc.user_id == ^user_id and uwc.widget_code == ^widget_code and uwc.device == ^device)
    |> Repo.one(prefix: prefix)
  end

  def get_user_widget_config!(id, prefix), do: Repo.get!(UserWidgetConfig, id, prefix: prefix)

  def create_or_update_configs(attrs, user, prefix) do
    user_id = get_user_from_map(attrs, user)

    list_user_widget_configs_for_user(user_id, attrs["device"], prefix)
    |> Stream.map(&Task.async(fn -> delete_user_widget_config(&1, prefix) end))
    |> Enum.map(&Task.await/1)

    result =
      attrs["config"]
      |> Stream.map(fn config ->
            config |> Map.put("device", attrs["device"]) |> Map.put("user_id", user_id)
         end)
      |> Stream.map(&Task.async(fn -> create_user_widget_config(&1, prefix) end))
      |> Enum.map(&Task.await/1)

    failures = get_success_or_failure_list(result, :error)
    case length(failures) do
      0 ->
        {:ok,
        get_success_or_failure_list(result, :ok) |> preload_widgets()}

      _ ->
        {:multiple_error, failures}
    end
  end

  def create_user_widget_config(attrs \\ %{}, prefix) do
    %UserWidgetConfig{}
    |> UserWidgetConfig.changeset(attrs)
    |> validate_widget_code()
    |> Repo.insert(prefix: prefix)
  end

  defp validate_widget_code(cs) do
    code = get_field(cs, :widget_code)
    cond do
      code && Common.get_widget_by_code(code) ->
        cs
      true ->
        add_error(cs, :widget_code, "is invalid")
    end
  end

  def update_user_widget_config(%UserWidgetConfig{} = user_widget_config, attrs, prefix) do
    user_widget_config
    |> UserWidgetConfig.changeset(attrs)
    |> validate_widget_code()
    |> Repo.update(prefix: prefix)
  end

  def delete_user_widget_config(%UserWidgetConfig{} = user_widget_config, prefix) do
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
