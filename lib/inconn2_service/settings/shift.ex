defmodule Inconn2Service.Settings.Shift do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.AssetConfig.Site

  schema "shifts" do
    field :applicable_days, {:array, :integer}
    field :end_date, :date
    field :end_time, :time
    field :name, :string
    field :start_date, :date
    field :start_time, :time
    field :active, :boolean, default: true
    field :code, :string
    belongs_to :site, Site
    timestamps()
  end

  @doc false
  def changeset(shift, attrs) do
    shift
    |> cast(attrs, [
      :name,
      :start_time,
      :end_time,
      :applicable_days,
      :start_date,
      :end_date,
      :site_id,
      :active,
      :code
    ])
    |> validate_required([
      :name,
      :start_time,
      :end_time,
      :applicable_days,
      :start_date,
      :end_date,
      :site_id
    ])
    |> validate_date_order
    |> validate_applicable_days
    |> unique_constraint(:code)
    |> validate_code()
    |> assoc_constraint(:site)
  end

  defp validate_date_order(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    case Date.compare(start_date, end_date) do
      :gt -> add_error(changeset, :start_date, "cannot be later than 'end_date'")
      _ -> changeset
    end
  end

  defp validate_applicable_days(changeset) do
    applicable_days = get_field(changeset, :applicable_days)
    check_days = [1, 2, 3, 4, 5, 6, 7]

    # To check if the applicable days are within this value
    # 1 - Monday, 2 - Tuesday ... 7 Sunday
    case MapSet.subset?(MapSet.new(applicable_days), MapSet.new(check_days)) do
      true -> changeset
      _ -> add_error(changeset, :applicable_days, "cannot be anything other than 1,2,3,4,5,6,7")
    end
    # Date.day_of_week returns 1,2,3,4,5,6,7 depending on the start default date
  end


  defp validate_code(cs) do
    code = get_field(cs, :code, nil)
    cond do
      !is_nil(code) and String.match?(code, ~r/^[A-Z]/) and String.length(code) == 1 -> cs
      !is_nil(code) and String.match?(code, ~r/^[A-Z]/) -> add_error(cs, :code, "Code should be only one letter")
      !is_nil(code) -> add_error(cs, :code, "Code should be upper case")
      true -> cs
    end
  end

end
