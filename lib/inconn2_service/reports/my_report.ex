defmodule Inconn2Service.Reports.MyReport do
  alias Inconn2Service.Staff.User
  use Ecto.Schema
  import Ecto.Changeset

  schema "my_reports" do
    field :code, :string
    field :description, :string
    field :name, :string
    field :report_params, :map
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(my_report, attrs) do
    my_report
    |> cast(attrs, [:name, :description, :code, :report_params, :user_id])
    |> validate_required([:name, :description, :code, :report_params, :user_id])
    |> validate_inclusion(:code, ["AST", "TKT", "WOR", "INT"])
  end
end
