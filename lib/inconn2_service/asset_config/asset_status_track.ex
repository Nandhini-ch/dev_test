defmodule Inconn2Service.AssetConfig.AssetStatusTrack do
  use Ecto.Schema
  import Ecto.Changeset

  schema "asset_status_tracks" do
    field :asset_id, :integer
    field :asset_type, :string
    field :changed_date_time, :naive_datetime
    field :status_changed, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(asset_status_track, attrs) do
    asset_status_track
    |> cast(attrs, [:asset_id, :asset_type, :status_changed, :user_id, :changed_date_time])
    |> validate_required([:asset_id, :asset_type, :status_changed, :user_id, :changed_date_time])
  end
end
