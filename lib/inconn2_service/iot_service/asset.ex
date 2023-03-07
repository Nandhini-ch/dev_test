defmodule Inconn2Service.IotService.Asset do

  def list_assets() do
    [
      %{id: 1, name: "Asset 1", asset_type: "L"},
      %{id: 2, name: "Asset 2", asset_type: "L"},
      %{id: 3, name: "Asset 3", asset_type: "E"},
      %{id: 4, name: "Asset 4", asset_type: "E"}
    ]
  end
end
