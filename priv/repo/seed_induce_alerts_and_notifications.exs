alias Inconn2Service.AssetConfig

loc1 = AssetConfig.get_location!(1, "inc_bata")
eqp1 = AssetConfig.get_equipment!(1, "inc_bata")

AssetConfig.update_location(loc1, %{"status" => "BRK"}, "inc_bata", %{id: 1})
AssetConfig.update_equipment(eqp1, %{"status" => "BRK"}, "inc_bata", %{id: 1})
