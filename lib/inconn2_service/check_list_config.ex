defmodule Inconn2Service.CheckListConfig do
  @moduledoc """
  The CheckListConfig context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Inconn2Service.Repo

  alias Inconn2Service.CheckListConfig.Check

  @doc """
  Returns the list of checks.

  ## Examples

      iex> list_checks()
      [%Check{}, ...]

  """
  def list_checks(prefix) do
    Repo.all(Check, prefix: prefix)
  end

  @doc """
  Gets a single check.

  Raises `Ecto.NoResultsError` if the Check does not exist.

  ## Examples

      iex> get_check!(123)
      %Check{}

      iex> get_check!(456)
      ** (Ecto.NoResultsError)

  """
  def get_check!(id, prefix), do: Repo.get!(Check, id, prefix: prefix)

  @doc """
  Creates a check.

  ## Examples

      iex> create_check(%{field: value})
      {:ok, %Check{}}

      iex> create_check(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_check(attrs \\ %{}, prefix) do
    %Check{}
    |> Check.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a check.

  ## Examples

      iex> update_check(check, %{field: new_value})
      {:ok, %Check{}}

      iex> update_check(check, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_check(%Check{} = check, attrs, prefix) do
    check
    |> Check.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a check.

  ## Examples

      iex> delete_check(check)
      {:ok, %Check{}}

      iex> delete_check(check)
      {:error, %Ecto.Changeset{}}

  """
  def delete_check(%Check{} = check, prefix) do
    Repo.delete(check, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking check changes.

  ## Examples

      iex> change_check(check)
      %Ecto.Changeset{data: %Check{}}

  """
  def change_check(%Check{} = check, attrs \\ %{}) do
    Check.changeset(check, attrs)
  end

  alias Inconn2Service.CheckListConfig.CheckList

  @doc """
  Returns the list of check_lists.

  ## Examples

      iex> list_check_lists()
      [%CheckList{}, ...]

  """
  def list_check_lists(prefix) do
    Repo.all(CheckList, prefix: prefix)
  end

  @doc """
  Gets a single check_list.

  Raises `Ecto.NoResultsError` if the Check list does not exist.

  ## Examples

      iex> get_check_list!(123)
      %CheckList{}

      iex> get_check_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_check_list!(id, prefix), do: Repo.get!(CheckList, id, prefix: prefix)

  @doc """
  Creates a check_list.

  ## Examples

      iex> create_check_list(%{field: value})
      {:ok, %CheckList{}}

      iex> create_check_list(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_check_list(attrs \\ %{}, prefix) do
    %CheckList{}
    |> CheckList.changeset(attrs)
    |> validate_check_ids(prefix)
    |> Repo.insert(prefix: prefix)
  end

  defp validate_check_ids(cs, prefix) do
    ids = get_change(cs, :check_ids, nil)
    if ids != nil do
      checks = from(c in Check, where: c.id in ^ids )
              |> Repo.all(prefix: prefix)
      case length(ids) == length(checks) do
        true -> cs
        false -> add_error(cs, :check_ids, "Check IDs are invalid")
      end
    else
      cs
    end
  end
  @doc """
  Updates a check_list.

  ## Examples

      iex> update_check_list(check_list, %{field: new_value})
      {:ok, %CheckList{}}

      iex> update_check_list(check_list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_check_list(%CheckList{} = check_list, attrs, prefix) do
    check_list
    |> CheckList.changeset(attrs)
    |> validate_check_ids(prefix)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a check_list.

  ## Examples

      iex> delete_check_list(check_list)
      {:ok, %CheckList{}}

      iex> delete_check_list(check_list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_check_list(%CheckList{} = check_list, prefix) do
    Repo.delete(check_list, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking check_list changes.

  ## Examples

      iex> change_check_list(check_list)
      %Ecto.Changeset{data: %CheckList{}}

  """
  def change_check_list(%CheckList{} = check_list, attrs \\ %{}) do
    CheckList.changeset(check_list, attrs)
  end
end
