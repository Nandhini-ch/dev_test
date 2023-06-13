defmodule Inconn2Service.ContractManagement.SlaEmailConfig do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sla_email_config" do
    field :category, :string
    field :email_list, {:array, :map}, default: []
    timestamps()
  end

  @doc false
  def changeset(sla, attrs) do
    sla
    |> cast(attrs, [
      :category,
      :email_list
    ])
  end
end
