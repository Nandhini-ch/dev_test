alias Inconn2Service.{Account, AssetConfig}

bt = %{"name" => "Shoe Retail"}
{:ok, btrec} = Account.create_business_type(bt)

client = %{
  "company_name" => "Bata Shoe Company",
  "business_type_id" => btrec.id,
  "sub_domain" => "bata",
  "address" => %{
    "address_line1" => "18, First Street",
    "address_line2" => "Anna Nagar",
    "city" => "Chennai",
    "state" => "Tamilnadu",
    "country" => "India",
    "postcode" => "600040"
  },
  "contact" => %{
    "first_name" => "Bala",
    "last_name" => "Chandar",
    "designation" => "Sales Head",
    "land_line" => "+91-44-2457727",
    "mobile" => "+91-9840022485",
    "email" => "balac@bata.co.in"
  }
}

case Account.create_licensee(client) do
  {:ok, lic} -> IO.inspect(lic)
  {:error, cs} -> IO.inspect(cs)
end

site = %{
  "name" => "Mountroad",
  "description" => "Main branch at Mount road",
  "site_code" => "BRCHN_MNTRD"
}

sc =
  case AssetConfig.create_site(site, "inc_bata") do
    {:ok, site_created} -> IO.inspect(site_created)
    {:error, cs} -> IO.inspect(cs)
  end

a1 = %{"name" => "Open floor", "asset_type" => "L", "site_id" => sc.id}
a2 = %{"name" => "Electrical", "asset_type" => "E", "site_id" => sc.id}
{:ok, a1c} = AssetConfig.create_asset_category(a1, "inc_bata")
{:ok, a2c} = AssetConfig.create_asset_category(a2, "inc_bata")

b1 = %{"name" => "Building1", "location_code" => "LOC_BUILD1", "site_id" => sc.id, "asset_category_id" => a1c.id}
b2 = %{"name" => "Building2", "location_code" => "LOC_BUILD2", "site_id" => sc.id, "asset_category_id" => a1c.id}
{:ok, b1c} = AssetConfig.create_location(b1, "inc_bata")
{:ok, b2c} = AssetConfig.create_location(b2, "inc_bata")

{:ok, b1_f1} =
  %{
    "parent_id" => b1c.id,
    "name" => "B1 Floor1",
    "location_code" => "LOC_B1F1",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b1_f2} =
  %{
    "parent_id" => b1c.id,
    "name" => "B1 Floor2",
    "location_code" => "LOC_B1F2",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b2_f1} =
  %{
    "parent_id" => b2c.id,
    "name" => "B2 Floor1",
    "location_code" => "LOC_B2F1",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b2_f2} =
  %{
    "parent_id" => b2c.id,
    "name" => "B2 Floor2",
    "location_code" => "LOC_B2F2",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b1_f1_z1} =
  %{
    "parent_id" => b1_f1.id,
    "name" => "B1 F1 Zone1",
    "location_code" => "LOC_B1F1Z1",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b1_f1_z2} =
  %{
    "parent_id" => b1_f1.id,
    "name" => "B1 F1 Zone2",
    "location_code" => "LOC_B1F1Z2",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b2_f1_z1} =
  %{
    "parent_id" => b2_f1.id,
    "name" => "B2 F1 Zone1",
    "location_code" => "LOC_B2F1Z1",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b2_f1_z2} =
  %{
    "parent_id" => b2_f1.id,
    "name" => "B2 F1 Zone2",
    "location_code" => "LOC_B2F1Z2",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

{:ok, b2_f1_z3} =
  %{
    "parent_id" => b2_f1.id,
    "name" => "B2 F1 Zone3",
    "location_code" => "LOC_B2F1Z3",
    "site_id" => sc.id,
    "asset_category_id" => a1c.id
  }
  |> AssetConfig.create_location("inc_bata")

  dg1 = %{"name" => "Diesel Generator 1", "equipment_code" => "EQ_DG1", "site_id" => sc.id, "asset_category_id" => a2c.id}
  dg2 = %{"name" => "Diesel Generator 2", "equipment_code" => "EQ_DG2", "site_id" => sc.id, "asset_category_id" => a2c.id}
  {:ok, dg1c} = AssetConfig.create_equipment(dg1, "inc_bata")
  {:ok, dg2c} = AssetConfig.create_equipment(dg2, "inc_bata")

  {:ok, dg1_ic} =
    %{
      "parent_id" => dg1c.id,
      "name" => "IC Engine",
      "equipment_code" => "EQ_DG1_IC",
      "site_id" => sc.id,
      "asset_category_id" => a2c.id
    }
    |> AssetConfig.create_equipment("inc_bata")

  {:ok, dg1_al} =
    %{
      "parent_id" => dg1c.id,
      "name" => "Alternator",
      "equipment_code" => "EQ_DG1_AL",
      "site_id" => sc.id,
      "asset_category_id" => a2c.id
    }
    |> AssetConfig.create_equipment("inc_bata")

  {:ok, dg2_ic} =
    %{
      "parent_id" => dg2c.id,
      "name" => "IC Engine",
      "equipment_code" => "EQ_DG2_IC",
      "site_id" => sc.id,
      "asset_category_id" => a2c.id
    }
    |> AssetConfig.create_equipment("inc_bata")

  {:ok, dg2_al} =
    %{
      "parent_id" => dg2c.id,
      "name" => "Alternator",
      "equipment_code" => "EQ_DG2_AL",
      "site_id" => sc.id,
      "asset_category_id" => a2c.id
    }
    |> AssetConfig.create_equipment("inc_bata")
