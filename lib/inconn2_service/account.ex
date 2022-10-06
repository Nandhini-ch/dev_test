defmodule Inconn2Service.Account do

  import Ecto.Query, warn: false
  alias Inconn2Service.Repo
  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Staff

  alias Inconn2Service.Account.BusinessType
  alias Inconn2Service.SeedFeatures

  def list_business_types do
    Repo.all(BusinessType)
  end

  def list_business_types(_query_params) do
    BusinessType
    |> Repo.add_active_filter()
    |> Repo.all()
  end

  def get_business_type!(id), do: Repo.get!(BusinessType, id)

  def create_business_type(attrs \\ %{}) do
    %BusinessType{}
    |> BusinessType.changeset(attrs)
    |> Repo.insert()
  end

  def update_business_type(%BusinessType{} = business_type, attrs) do
    business_type
    |> BusinessType.changeset(attrs)
    |> Repo.update()
  end

  def delete_business_type(%BusinessType{} = business_type) do
    Repo.delete(business_type)
  end


  def change_business_type(%BusinessType{} = business_type, attrs \\ %{}) do
    BusinessType.changeset(business_type, attrs)
  end

  alias Inconn2Service.Account.Licensee

  def list_licensees do
    Repo.all(Licensee) |> Repo.preload(:business_type)
  end


  def get_licensee!(id), do: Repo.get!(Licensee, id) |> Repo.preload(:business_type)

  def get_licensee_by_sub_domain(sub_domain) do
    Repo.get_by(Licensee, sub_domain: sub_domain) |> Repo.preload(:business_type)
  end


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

        #Seed role profiles
        SeedFeatures.seed_role_profiles(prefix)

        role_profile = Staff.get_role_profile_by_name!("Admin", prefix) |> Staff.filter_permissions()

        {:ok, role} = Staff.create_role(%{"name" => "Licensee Admin",
                                          "description" => "Super Admin for licensee. Has access to all features",
                                          "role_profile_id" => role_profile.id,
                                          "permissions" => role_profile.permissions},
                                        prefix)
        Staff.create_licensee_admin(%{
          "username" => licensee.contact.email,
          "email" => licensee.contact.email,
          "password" => licensee.contact.mobile,
          "mobile_no" => licensee.contact.mobile,
          "role_id" => role.id,
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

  def update_licensee(%Licensee{} = licensee, attrs) do
    licensee
    |> Licensee.changeset(attrs)
    |> Repo.update()
  end

  def delete_licensee(%Licensee{} = licensee) do
    Repo.delete(licensee)
  end

  def change_licensee(%Licensee{} = licensee, attrs \\ %{}) do
    Licensee.changeset(licensee, attrs)
  end
end
