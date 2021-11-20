defmodule Inconn2Service.Account do
  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Staff

  alias Inconn2Service.Account.BusinessType
  alias Inconn2Service.CreateModuleFeatureRoles

  @doc """
  Returns the list of business_types.

  ## Examples

      iex> list_business_types()
      [%BusinessType{}, ...]

  """
  def list_business_types do
    Repo.all(BusinessType)
  end

  def list_business_types(query_params) do
    BusinessType
    |> Repo.add_active_filter(query_params)
    |> Repo.all()
  end

  @doc """
  Gets a single business_type.

  Raises `Ecto.NoResultsError` if the Business type does not exist.

  ## Examples

      iex> get_business_type!(123)
      %BusinessType{}

      iex> get_business_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_business_type!(id), do: Repo.get!(BusinessType, id)

  @doc """
  Creates a business_type.

  ## Examples

      iex> create_business_type(%{field: value})
      {:ok, %BusinessType{}}

      iex> create_business_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_business_type(attrs \\ %{}) do
    %BusinessType{}
    |> BusinessType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a business_type.

  ## Examples

      iex> update_business_type(business_type, %{field: new_value})
      {:ok, %BusinessType{}}

      iex> update_business_type(business_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_business_type(%BusinessType{} = business_type, attrs) do
    business_type
    |> BusinessType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a business_type.

  ## Examples

      iex> delete_business_type(business_type)
      {:ok, %BusinessType{}}

      iex> delete_business_type(business_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_business_type(%BusinessType{} = business_type) do
    Repo.delete(business_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking business_type changes.

  ## Examples

      iex> change_business_type(business_type)
      %Ecto.Changeset{data: %BusinessType{}}

  """
  def change_business_type(%BusinessType{} = business_type, attrs \\ %{}) do
    BusinessType.changeset(business_type, attrs)
  end

  alias Inconn2Service.Account.Licensee

  @doc """
  Returns the list of licensees.

  ## Examples

      iex> list_licensees()
      [%Licensee{}, ...]

  """
  def list_licensees do
    Repo.all(Licensee) |> Repo.preload(:business_type)
  end

  @doc """
  Gets a single licensee.

  Raises `Ecto.NoResultsError` if the Licensee does not exist.

  ## Examples

      iex> get_licensee!(123)
      %Licensee{}

      iex> get_licensee!(456)
      ** (Ecto.NoResultsError)

  """
  def get_licensee!(id), do: Repo.get!(Licensee, id) |> Repo.preload(:business_type)

  def get_licensee_by_sub_domain(sub_domain) do
    Repo.get_by(Licensee, sub_domain: sub_domain) |> Repo.preload(:business_type)
  end

  @doc """
  Creates a licensee.

  ## Examples

      iex> create_licensee(%{field: value})
      {:ok, %Licensee{}}

      iex> create_licensee(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_licensee(attrs \\ %{}) do
    result =
      %Licensee{}
      |> Licensee.changeset(attrs)
      |> Repo.insert()

    IO.inspect(result)
    IO.puts("creating licensee")

    case result do
      {:ok, licensee} ->
        IO.puts("creating create_tenant")
        create_tenant(licensee)
        IO.inspect(licensee)
        party_type = licensee.party_type
        IO.puts("creating party_type")
        IO.inspect(party_type)

        {:ok, return_party} =
          IO.inspect(
            AssetConfig.create_default_party(licensee, Triplex.to_prefix(licensee.sub_domain))
          )

        IO.inspect(return_party)
        prefix = "inc_" <> attrs["sub_domain"]
        role = CreateModuleFeatureRoles.seed_features(prefix)
        #{:ok, role} = Staff.create_role(%{"name" => "Licensee Admin", "description" => "Super Admin for licensee. Has access to all features"}, prefix)
        Staff.create_licensee_admin(%{
          "username" => licensee.contact.email,
          "password" => licensee.contact.mobile,
          "role_ids" => [role.id],
          "party_id" => return_party.id
        }, prefix)
        {:ok, Repo.get!(Licensee, licensee.id) |> Repo.preload(:business_type)}

      _ ->
        result
    end
  end

  defp create_tenant(licensee) do
    case IO.inspect(Triplex.create(licensee.sub_domain)) do
      {:ok, workspace} ->
        IO.inspect(workspace)
        {:ok, licensee}
        IO.inspect(workspace)

      _ ->
        delete_licensee(licensee)
        {:error, {:triplex, "Not able to create tenant schema"}}
    end
  end

  @doc """
  Updates a licensee.

  ## Examples

      iex> update_licensee(licensee, %{field: new_value})
      {:ok, %Licensee{}}

      iex> update_licensee(licensee, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_licensee(%Licensee{} = licensee, attrs) do
    licensee
    |> Licensee.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a licensee.

  ## Examples

      iex> delete_licensee(licensee)
      {:ok, %Licensee{}}

      iex> delete_licensee(licensee)
      {:error, %Ecto.Changeset{}}

  """
  def delete_licensee(%Licensee{} = licensee) do
    Repo.delete(licensee)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking licensee changes.

  ## Examples

      iex> change_licensee(licensee)
      %Ecto.Changeset{data: %Licensee{}}

  """
  def change_licensee(%Licensee{} = licensee, attrs \\ %{}) do
    Licensee.changeset(licensee, attrs)
  end
end
