defmodule HomecloudWeb.Devices.DeviceControllerTest do
  use HomecloudWeb.ConnCase

  import Homecloud.DevicesFixtures

  alias Homecloud.Devices.Device

  @create_attrs %{
    hostname: "macbook"
  }
  @update_attrs %{
    expired_at: ~U[2023-05-20 05:54:00Z],
    ipv6: "fe80::1808:a530:af1a:9b5d"
  }
  @invalid_attrs %{expired_at: nil, ipv6: nil, hostname: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all devices", %{conn: conn} do
      conn = get(conn, ~p"/api/devices")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create device" do
    test "renders device when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/devices", device: @create_attrs)

      assert %{
               "hostname" => hostname,
               "secret_key" => secret_key
             } = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/devices/#{hostname}")

      assert %{
               "hostname" => ^hostname,
               "expired_at" => nil,
               "ipv6" => nil
             } = json_response(conn, 200)["data"]

      assert %Device{secret_key: ^secret_key} = Homecloud.Devices.get_device!(hostname)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/devices", device: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update device" do
    setup [:create_device]

    test "renders device when data is valid", %{
      conn: conn,
      device: %Device{hostname: hostname} = device
    } do
      conn = put(conn, ~p"/api/devices/#{device.hostname}", device: @update_attrs)
      assert %{"hostname" => ^hostname} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/devices/#{hostname}")

      assert %{
               "hostname" => ^hostname,
               "expired_at" => "2023-05-20T05:54:00Z",
               "ipv6" => "fe80::1808:a530:af1a:9b5d"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, device: device} do
      conn = put(conn, ~p"/api/devices/#{device.hostname}", device: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete device" do
    setup [:create_device]

    test "deletes chosen device", %{conn: conn, device: device} do
      conn = delete(conn, ~p"/api/devices/#{device.hostname}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/devices/#{device.hostname}")
      end
    end
  end

  defp create_device(_) do
    device = device_fixture()
    %{device: device}
  end
end
