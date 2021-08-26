defmodule Inconn2ServiceWeb.PartyControllerTest do
  use Inconn2ServiceWeb.ConnCase

  alias Inconn2Service.AssetConfig
  alias Inconn2Service.AssetConfig.Party

  @create_attrs %{
    contract_end_date: ~D[2010-04-17],
    contract_start_date: ~D[2010-04-17],
    license_no: "some license_no",
    licensee: "some licensee",
    org_name: "some org_name",
    party_type: [],
    preferred_service: "some preferred_service",
    rates_per_hour: 120.5,
    service_id: "some service_id",
    service_type: "some service_type",
    type_of_maintenance: []
  }
  @update_attrs %{
    contract_end_date: ~D[2011-05-18],
    contract_start_date: ~D[2011-05-18],
    license_no: "some updated license_no",
    licensee: "some updated licensee",
    org_name: "some updated org_name",
    party_type: [],
    preferred_service: "some updated preferred_service",
    rates_per_hour: 456.7,
    service_id: "some updated service_id",
    service_type: "some updated service_type",
    type_of_maintenance: []
  }
  @invalid_attrs %{contract_end_date: nil, contract_start_date: nil, license_no: nil, licensee: nil, org_name: nil, party_type: nil, preferred_service: nil, rates_per_hour: nil, service_id: nil, service_type: nil, type_of_maintenance: nil}

  def fixture(:party) do
    {:ok, party} = AssetConfig.create_party(@create_attrs)
    party
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all parties", %{conn: conn} do
      conn = get(conn, Routes.party_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create party" do
    test "renders party when data is valid", %{conn: conn} do
      conn = post(conn, Routes.party_path(conn, :create), party: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.party_path(conn, :show, id))

      assert %{
               "id" => id,
               "contract_end_date" => "2010-04-17",
               "contract_start_date" => "2010-04-17",
               "license_no" => "some license_no",
               "licensee" => "some licensee",
               "org_name" => "some org_name",
               "party_type" => [],
               "preferred_service" => "some preferred_service",
               "rates_per_hour" => 120.5,
               "service_id" => "some service_id",
               "service_type" => "some service_type",
               "type_of_maintenance" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.party_path(conn, :create), party: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update party" do
    setup [:create_party]

    test "renders party when data is valid", %{conn: conn, party: %Party{id: id} = party} do
      conn = put(conn, Routes.party_path(conn, :update, party), party: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.party_path(conn, :show, id))

      assert %{
               "id" => id,
               "contract_end_date" => "2011-05-18",
               "contract_start_date" => "2011-05-18",
               "license_no" => "some updated license_no",
               "licensee" => "some updated licensee",
               "org_name" => "some updated org_name",
               "party_type" => [],
               "preferred_service" => "some updated preferred_service",
               "rates_per_hour" => 456.7,
               "service_id" => "some updated service_id",
               "service_type" => "some updated service_type",
               "type_of_maintenance" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, party: party} do
      conn = put(conn, Routes.party_path(conn, :update, party), party: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete party" do
    setup [:create_party]

    test "deletes chosen party", %{conn: conn, party: party} do
      conn = delete(conn, Routes.party_path(conn, :delete, party))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.party_path(conn, :show, party))
      end
    end
  end

  defp create_party(_) do
    party = fixture(:party)
    %{party: party}
  end
end
