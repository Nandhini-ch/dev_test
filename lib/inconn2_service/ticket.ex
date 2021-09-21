defmodule Inconn2Service.Ticket do
  @moduledoc """
  The Ticket context.
  """

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.Ticket.WorkrequestCategory

  @doc """
  Returns the list of workrequest_categories.

  ## Examples

      iex> list_workrequest_categories()
      [%WorkrequestCategory{}, ...]

  """
  def list_workrequest_categories(prefix) do
    Repo.all(WorkrequestCategory, prefix: prefix)
  end

  @doc """
  Gets a single workrequest_category.

  Raises `Ecto.NoResultsError` if the Workrequest category does not exist.

  ## Examples

      iex> get_workrequest_category!(123)
      %WorkrequestCategory{}

      iex> get_workrequest_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_workrequest_category!(id, prefix), do: Repo.get!(WorkrequestCategory, id, prefix: prefix)

  @doc """
  Creates a workrequest_category.

  ## Examples

      iex> create_workrequest_category(%{field: value})
      {:ok, %WorkrequestCategory{}}

      iex> create_workrequest_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_workrequest_category(attrs \\ %{}, prefix) do
    %WorkrequestCategory{}
    |> WorkrequestCategory.changeset(attrs)
    |> Repo.insert(prefix: prefix)
  end

  @doc """
  Updates a workrequest_category.

  ## Examples

      iex> update_workrequest_category(workrequest_category, %{field: new_value})
      {:ok, %WorkrequestCategory{}}

      iex> update_workrequest_category(workrequest_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_workrequest_category(%WorkrequestCategory{} = workrequest_category, attrs, prefix) do
    workrequest_category
    |> WorkrequestCategory.changeset(attrs)
    |> Repo.update(prefix: prefix)
  end

  @doc """
  Deletes a workrequest_category.

  ## Examples

      iex> delete_workrequest_category(workrequest_category)
      {:ok, %WorkrequestCategory{}}

      iex> delete_workrequest_category(workrequest_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_workrequest_category(%WorkrequestCategory{} = workrequest_category, prefix) do
    Repo.delete(workrequest_category, prefix: prefix)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workrequest_category changes.

  ## Examples

      iex> change_workrequest_category(workrequest_category)
      %Ecto.Changeset{data: %WorkrequestCategory{}}

  """
  def change_workrequest_category(%WorkrequestCategory{} = workrequest_category, attrs \\ %{}) do
    WorkrequestCategory.changeset(workrequest_category, attrs)
  end
end
