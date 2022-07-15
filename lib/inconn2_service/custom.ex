defmodule Inconn2Service.Custom do
  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Custom.CustomFields

  def list_custom_fields(prefix) do
    Repo.all(CustomFields, prefix: prefix)
  end

  def get_custom_fields!(entity, prefix) do
    Repo.one(from(c in CustomFields, where: c.entity == ^entity), prefix: prefix)
  end

  def create_custom_fields(attrs \\ %{}, prefix) do
    %CustomFields{}
    |> CustomFields.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  def update_custom_fields(%CustomFields{} = custom_fields, attrs, prefix) do
    custom_fields
    |> CustomFields.changeset(add_list_in_attrs(attrs, custom_fields))
    |> Repo.update(prefix: prefix)
  end

  def delete_custom_fields(%CustomFields{} = custom_fields, prefix) do
    Repo.delete(custom_fields, prefix: prefix)
  end

  def change_custom_fields(%CustomFields{} = custom_fields, attrs \\ %{}) do
    CustomFields.changeset(custom_fields, attrs)
  end

  defp add_list_in_attrs(attrs, custom_fields) do
    Map.put(attrs, "fields", add_list(attrs["fields"], custom_fields.fields))
  end

  defp add_list(nil, existing_custom_fields), do: existing_custom_fields
  defp add_list(new_custom_fields, existing_custom_fields), do: new_custom_fields ++ existing_custom_fields
end
