defmodule Homecloud.DevicesTest do
  use Homecloud.DataCase

  alias Homecloud.Devices

  describe "devices" do
    alias Homecloud.Devices.Device

    import Homecloud.DevicesFixtures

    @invalid_attrs %{secret_key: nil, hostname: nil}
    @valid_attrs %{
      expired_at: ~U[2023-05-19 05:54:00Z],
      ipv6: "some ipv6",
      hostname: "some name",
      secret_key: "xfdf7TzmTK06skGN"
    }

    test "list_devices/0 returns all devices" do
      device = device_fixture()
      assert Devices.list_devices() == [device]
    end

    test "get_device!/1 returns the device with given id" do
      device = device_fixture()
      assert Devices.get_device!(device.hostname) == device
    end

    test "create_device/1 with valid data creates a device" do
      assert {:ok, %Device{} = device} = Devices.create_device(@valid_attrs)
      assert device.expired_at == ~U[2023-05-19 05:54:00Z]
      assert device.ipv6 == "some ipv6"
      assert device.hostname == "some name"
    end

    test "create_device/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Devices.create_device(@invalid_attrs)
    end

    test "update_device/2 with valid data updates the device" do
      device = device_fixture()
      update_attrs = %{expired_at: ~U[2023-05-20 05:54:00Z], ipv6: "some updated ipv6"}

      assert {:ok, %Device{} = device} = Devices.update_device(device, update_attrs)
      assert device.expired_at == ~U[2023-05-20 05:54:00Z]
      assert device.ipv6 == "some updated ipv6"
    end

    test "update_device/2 with invalid data returns error changeset" do
      device = device_fixture()
      assert {:error, %Ecto.Changeset{}} = Devices.update_device(device, @invalid_attrs)
      assert device == Devices.get_device!(device.hostname)
    end

    test "delete_device/1 deletes the device" do
      device = device_fixture()
      assert {:ok, %Device{}} = Devices.delete_device(device)
      assert_raise Ecto.NoResultsError, fn -> Devices.get_device!(device.hostname) end
    end

    test "change_device/1 returns a device changeset" do
      device = device_fixture()
      assert %Ecto.Changeset{} = Devices.change_device(device)
    end
  end
end
