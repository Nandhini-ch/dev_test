defmodule Inconn2Service.SettingsTest do
  use Inconn2Service.DataCase

  alias Inconn2Service.Settings

  describe "shifts" do
    alias Inconn2Service.Settings.Shift

    @valid_attrs %{applicable_days: [], end_date: ~D[2010-04-17], end_time: ~T[14:00:00], name: "some name", start_date: ~D[2010-04-17], start_time: ~T[14:00:00]}
    @update_attrs %{applicable_days: [], end_date: ~D[2011-05-18], end_time: ~T[15:01:01], name: "some updated name", start_date: ~D[2011-05-18], start_time: ~T[15:01:01]}
    @invalid_attrs %{applicable_days: nil, end_date: nil, end_time: nil, name: nil, start_date: nil, start_time: nil}

    def shift_fixture(attrs \\ %{}) do
      {:ok, shift} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_shift()

      shift
    end

    test "list_shifts/0 returns all shifts" do
      shift = shift_fixture()
      assert Settings.list_shifts() == [shift]
    end

    test "get_shift!/1 returns the shift with given id" do
      shift = shift_fixture()
      assert Settings.get_shift!(shift.id) == shift
    end

    test "create_shift/1 with valid data creates a shift" do
      assert {:ok, %Shift{} = shift} = Settings.create_shift(@valid_attrs)
      assert shift.applicable_days == []
      assert shift.end_date == ~D[2010-04-17]
      assert shift.end_time == ~T[14:00:00]
      assert shift.name == "some name"
      assert shift.start_date == ~D[2010-04-17]
      assert shift.start_time == ~T[14:00:00]
    end

    test "create_shift/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_shift(@invalid_attrs)
    end

    test "update_shift/2 with valid data updates the shift" do
      shift = shift_fixture()
      assert {:ok, %Shift{} = shift} = Settings.update_shift(shift, @update_attrs)
      assert shift.applicable_days == []
      assert shift.end_date == ~D[2011-05-18]
      assert shift.end_time == ~T[15:01:01]
      assert shift.name == "some updated name"
      assert shift.start_date == ~D[2011-05-18]
      assert shift.start_time == ~T[15:01:01]
    end

    test "update_shift/2 with invalid data returns error changeset" do
      shift = shift_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_shift(shift, @invalid_attrs)
      assert shift == Settings.get_shift!(shift.id)
    end

    test "delete_shift/1 deletes the shift" do
      shift = shift_fixture()
      assert {:ok, %Shift{}} = Settings.delete_shift(shift)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_shift!(shift.id) end
    end

    test "change_shift/1 returns a shift changeset" do
      shift = shift_fixture()
      assert %Ecto.Changeset{} = Settings.change_shift(shift)
    end
  end
end
