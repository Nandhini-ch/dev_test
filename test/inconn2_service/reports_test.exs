defmodule Inconn2Service.ReportsTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Reports

  describe "my_reports" do
    alias Inconn2Service.Reports.MyReport

    @valid_attrs %{code: "some code", description: "some description", name: "some name", report_params: %{}}
    @update_attrs %{code: "some updated code", description: "some updated description", name: "some updated name", report_params: %{}}
    @invalid_attrs %{code: nil, description: nil, name: nil, report_params: nil}

    def my_report_fixture(attrs \\ %{}) do
      {:ok, my_report} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Reports.create_my_report()

      my_report
    end

    test "list_my_reports/0 returns all my_reports" do
      my_report = my_report_fixture()
      assert Reports.list_my_reports() == [my_report]
    end

    test "get_my_report!/1 returns the my_report with given id" do
      my_report = my_report_fixture()
      assert Reports.get_my_report!(my_report.id) == my_report
    end

    test "create_my_report/1 with valid data creates a my_report" do
      assert {:ok, %MyReport{} = my_report} = Reports.create_my_report(@valid_attrs)
      assert my_report.code == "some code"
      assert my_report.description == "some description"
      assert my_report.name == "some name"
      assert my_report.report_params == %{}
    end

    test "create_my_report/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reports.create_my_report(@invalid_attrs)
    end

    test "update_my_report/2 with valid data updates the my_report" do
      my_report = my_report_fixture()
      assert {:ok, %MyReport{} = my_report} = Reports.update_my_report(my_report, @update_attrs)
      assert my_report.code == "some updated code"
      assert my_report.description == "some updated description"
      assert my_report.name == "some updated name"
      assert my_report.report_params == %{}
    end

    test "update_my_report/2 with invalid data returns error changeset" do
      my_report = my_report_fixture()
      assert {:error, %Ecto.Changeset{}} = Reports.update_my_report(my_report, @invalid_attrs)
      assert my_report == Reports.get_my_report!(my_report.id)
    end

    test "delete_my_report/1 deletes the my_report" do
      my_report = my_report_fixture()
      assert {:ok, %MyReport{}} = Reports.delete_my_report(my_report)
      assert_raise Ecto.NoResultsError, fn -> Reports.get_my_report!(my_report.id) end
    end

    test "change_my_report/1 returns a my_report changeset" do
      my_report = my_report_fixture()
      assert %Ecto.Changeset{} = Reports.change_my_report(my_report)
    end
  end
end
