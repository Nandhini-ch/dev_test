defmodule Inconn2Service.InventoryManagement.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Inconn2Service.InventoryManagement.{InventoryItem, Store, InventorySupplier, UnitOfMeasurement}

  schema "transactions" do
    field :aisle, :string
    field :approver_user_id, :integer
    field :bin, :string
    field :cost, :float
    field :dc_file, :binary
    field :dc_no, :string
    field :quantity, :float
    field :remarks, :string
    field :row, :string
    field :transaction_date, :date
    field :transaction_reference, :string
    field :transaction_time, :time
    field :transaction_type, :string
    field :transaction_user_id, :integer
    field :unit_price, :float
    field :work_order_id, :integer
    field :is_approval_required, :boolean, default: false
    field :is_approved, :string
    field :is_acknowledged, :string
    field :requester_name, :string
    field :emp_id, :string
    field :authorized_by, :string
    field :department, :string
    field :status, :string, default: "CR"
    # field :item_id, :id
    belongs_to :inventory_item, InventoryItem
    # field :unit_of_measurement_id, :id
    belongs_to :unit_of_measurement, UnitOfMeasurement
    # field :store_id, :id
    belongs_to :store, Store
    belongs_to :inventory_supplier, InventorySupplier

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:transaction_reference, :transaction_type, :inventory_item_id, :unit_of_measurement_id, :store_id,
                              :transaction_user_id, :approver_user_id, :quantity, :unit_price, :aisle, :row, :bin, :cost, :remarks,
                              :is_approval_required, :is_approved, :inventory_supplier_id, :transaction_date, :transaction_time,
                              :dc_no, :dc_file, :requester_name, :emp_id, :authorized_by, :department, :status])
    |> validate_required([:transaction_reference, :transaction_type , :inventory_item_id, :unit_of_measurement_id,
                          :store_id,  :quantity,  :is_approval_required, :transaction_date, :transaction_time])
    |> validate_inclusion(:transaction_type, ["IN",  "IS"])
    |> set_is_acknowledged()
    |> set_is_approved()
    |> validate_inclusion(:is_acknowledged, ["ACK", "NACK", "RJ"])
    |> validate_inclusion(:is_approved, ["AP", "NA", "RJ"])
    |> validate_fields_based_on_transaction_type()
    |> validate_status_for_issue()
  end

  def update_changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:is_acknowledged, :is_approved, :status, :transaction_type])
    |> validate_inclusion(:is_acknowledged, ["YES", "NO", "RJ"])
    |> validate_inclusion(:is_approved, ["AP", "NA", "RJ"])
    |> change_is_acknowledged_for_acnkowledge()
    |> validate_status_for_issue()
  end

  defp validate_status_for_issue(cs) do
    case get_field(cs, :transaction_type) do
      # "IN" -> validate_inclusion(cs, :status, ["CR", "CP"])
      "IS" -> validate_inclusion(cs, :status, ["CR", "AP", "ACKP", "ACK"])
      _ -> cs
    end
  end

  def change_is_acknowledged_for_acnkowledge(cs) do
    case get_field(cs, :is_acknowledged, nil) do
      "ACK" -> change(cs, %{status: "ACK"})
      _ -> cs
    end
  end

  defp set_is_acknowledged(cs) do
    case get_field(cs, :transaction_type) do
      "IS" -> change(cs, %{is_acknowledged: "NACK"})
      _ -> cs
    end
  end

  defp set_is_approved(cs) do
    cond do
      get_field(cs, :transaction_type) == "IS" and get_field(cs, :is_approval_required) ->
        validate_required(cs, [:approver_user_id]) |> change(%{is_approved: "NA"})
      true ->
        cs
    end
  end

  defp validate_fields_based_on_transaction_type(cs) do
    case get_field(cs, :transaction_type, nil) do
      "IN" -> validate_required(cs, [:unit_price, :inventory_supplier_id, :dc_no])
      "IS" -> validate_required(cs, [:transaction_user_id])
    end
  end
end
