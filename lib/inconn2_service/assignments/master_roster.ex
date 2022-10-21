defmodule Inconn2Service.Assignments.MasterRoster do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Site
  alias Inconn2Service.Staff.Designation
  alias Inconn2Service.Assignments.Roster

  schema "master_rosters" do
    belongs_to :site, Site
    belongs_to :designation, Designation
    has_many :rosters, Roster
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(master_roster, attrs) do
    master_roster
    |> cast(attrs, [:site_id, :designation_id, :active])
    |> validate_required([:site_id, :designation_id, :active])
    |> assoc_constraint(:site)
    |> assoc_constraint(:designation)
  end
end
