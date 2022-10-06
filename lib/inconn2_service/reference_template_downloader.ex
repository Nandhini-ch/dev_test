defmodule Inconn2Service.ReferenceTemplateDownloader do

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.Workorder
  alias Inconn2Service.WorkOrderConfig
  alias Inconn2Service.CheckListConfig
  alias Inconn2Service.Staff
  alias Inconn2Service.Assignment
  alias Inconn2Service.Settings
  alias Inconn2Service.Inventory


  def download_asset_categories(prefix) do
    asset_categories = AssetConfig.list_asset_categories(prefix)

    header = [["id", "reference", "Name", "Asset Type", "Parent Id", "parent reference"]]

    body =
      Enum.map(asset_categories, fn r ->
        [r.id,"", r.name, r.asset_type, r.parent_id, ""]
      end)

    final_report = header ++ body
    final_report
  end

end
