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
    field :total_stock, :float
    field :is_minimum_stock_level_breached, :boolean
    field :minimum_stock_level, :float
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
    field :status, :string
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
    |> cast(attrs, [:transaction_reference, :transaction_type, :inventory_item_id, :total_stock, :minimum_stock_level, :is_minimum_stock_level_breached, :unit_of_measurement_id, :store_id,
                              :transaction_user_id, :approver_user_id, :quantity, :unit_price, :aisle, :row, :bin, :cost, :remarks,
                              :is_approval_required, :is_approved, :inventory_supplier_id, :transaction_date, :transaction_time,
                              :dc_no, :dc_file, :requester_name, :emp_id, :authorized_by, :department, :status])
    |> validate_required([:transaction_reference, :transaction_type , :inventory_item_id, :unit_of_measurement_id,
                          :store_id,  :quantity,  :is_approval_required, :transaction_date, :transaction_time])
    |> validate_inclusion(:transaction_type, ["IN",  "IS"])
    |> set_is_approved()
    |> set_is_acknowledged()
    |> validate_inclusion(:is_acknowledged, ["ACK", "NACK", "ACKP", "RJ"])
    |> validate_inclusion(:is_approved, ["AP", "NA", "RJ"])
    |> validate_fields_based_on_transaction_type()
    |> validate_status_for_issue()
  end

  def update_changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:is_acknowledged, :is_approved, :status, :transaction_type, :status])
    |> validate_inclusion(:is_acknowledged, ["ACK", "NACK", "ACKP", "RJ"])
    |> validate_inclusion(:is_approved, ["AP", "NA", "RJ"])
    |> change_status_for_approved()
    |> change_status_for_acknowledge()
    |> validate_status_for_issue()
  end

  defp validate_status_for_issue(cs) do
    case get_field(cs, :transaction_type) do
      "IN" -> validate_inclusion(cs, :status, ["CR", "CP"])
      "IS" -> validate_inclusion(cs, :status, ["CR", "NA", "APRJ", "AP", "ACKP", "ACKRJ", "CP"])
      _ -> cs
    end
  end

  def change_status_for_acknowledge(cs) do
    # IO.inspect("09897988-89980780")
    # IO.inspect(get_change(cs, :is_acknowledged, nil))
    case get_field(cs, :is_acknowledged, nil) do
      "ACKP" -> change(cs, %{status: "ACKP", is_acknowledged: "NACK"})
      "ACK" -> change(cs, %{status: "CP"})
      "RJ" -> change(cs, %{status: "ACKRJ"})
      _ -> cs
    end
  end

  defp change_status_for_approved(cs) do
    # IO.inspect(get_change(cs, :is_approved, nil))
    case get_field(cs, :is_approved, nil) do
      "AP" -> change(cs, %{status: "AP"})
      "RJ" -> change(cs, %{status: "APRJ"})
      _ -> cs
    end
  end

  defp set_is_acknowledged(cs) do
    is_approval_required = get_field(cs, :is_approval_required)
    transaction_type = get_field(cs, :transaction_type)
    cond do
      transaction_type == "IS" and is_approval_required -> cs
      transaction_type == "IS" -> change(cs, %{is_acknowledged: "NACK"})
      true -> cs
    end
    # case get_field(cs, :transaction_type) do
    #   "IS" ->
    #     change(cs, %{is_acknowledged: "NACK"})
    #   _ -> cs
    # end
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
