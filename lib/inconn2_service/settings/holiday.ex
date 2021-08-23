defmodule Inconn2Service.Settings.Holiday do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Site

  schema "bankholidays" do
    field :end_date, :date
    field :name, :string
    field :start_date, :date
    belongs_to :site, Site

    timestamps()
  end

  @doc false
  def changeset(holiday, attrs) do
    holiday
    |> cast(attrs, [:name, :start_date, :end_date, :site_id])
    |> validate_required([:name, :start_date, :end_date, :site_id])
    |> unique_constraint(:name, name: :index_holidays_dates)
    |> assoc_constraint(:site)
  end
end
