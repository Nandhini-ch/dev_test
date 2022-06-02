defmodule Inconn2Service.AppSettings do
  @moduledoc """
  The AppSettings context.
  """

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo

  alias Inconn2Service.AppSettings.Apk_version

  @doc """
  Returns the list of apk_versions.

  ## Examples

      iex> list_apk_versions()
      [%Apk_version{}, ...]

  """
  def list_apk_versions do
    Repo.all(Apk_version)
  end

  @doc """
  Gets a single apk_version.

  Raises `Ecto.NoResultsError` if the Apk version does not exist.

  ## Examples

      iex> get_apk_version!(123)
      %Apk_version{}

      iex> get_apk_version!(456)
      ** (Ecto.NoResultsError)

  """
  def get_apk_version!(id), do: Repo.get!(Apk_version, id)

  @doc """
  Creates a apk_version.

  ## Examples

      iex> create_apk_version(%{field: value})
      {:ok, %Apk_version{}}

      iex> create_apk_version(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_apk_version(attrs \\ %{}) do
    %Apk_version{}
    |> Apk_version.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a apk_version.

  ## Examples

      iex> update_apk_version(apk_version, %{field: new_value})
      {:ok, %Apk_version{}}

      iex> update_apk_version(apk_version, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_apk_version(%Apk_version{} = apk_version, attrs) do
    apk_version
    |> Apk_version.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a apk_version.

  ## Examples

      iex> delete_apk_version(apk_version)
      {:ok, %Apk_version{}}

      iex> delete_apk_version(apk_version)
      {:error, %Ecto.Changeset{}}

  """
  def delete_apk_version(%Apk_version{} = apk_version) do
    Repo.delete(apk_version)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking apk_version changes.

  ## Examples

      iex> change_apk_version(apk_version)
      %Ecto.Changeset{data: %Apk_version{}}

  """
  def change_apk_version(%Apk_version{} = apk_version, attrs \\ %{}) do
    Apk_version.changeset(apk_version, attrs)
  end
end
