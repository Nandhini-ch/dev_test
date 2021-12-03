defmodule Inconn2Service.Repo.Migrations.CreateInventoryTransactions do
  use Ecto.Migration

  def change do
    create table(:inventory_transactions) do
      add :transaction_type, :string
      add :price, :float
      add :supplier_id, :integer
      add :quantity, :float
      add :reference, :text
      add :inventory_location_id, :integer
      add :item_id, :integer
      add :uom_id, :integer
      add :workorder_id, :integer
      add :remarks, :text
      add :dc_attachment, :string
      add :dc_attachment_type, :string
      add :dc_reference, :string
      add :dc_date, :date
      add :gate_pass_attachment, :string
      add :gate_pass_attachment_type, :string
      add :gate_pass_reference, :string
      add :gate_pass_date, :date
      add :remaining, :float
      add :cost, :float
      add :cost_unit_uom_id, :integer
      add :issue_reference, :text
      add :user_id, :text

      timestamps()
    end

  end
end
