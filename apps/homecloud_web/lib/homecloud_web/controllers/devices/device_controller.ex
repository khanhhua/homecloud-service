defmodule HomecloudWeb.Devices.DeviceController do
  use HomecloudWeb, :controller

  alias Homecloud.Devices
  alias Homecloud.Devices.Device

  action_fallback HomecloudWeb.FallbackController

  def advertise(conn, %{"device" => %{"hostname" => hostname, "ipv6" => ipv6}}) do
    # TODO Header must include the secret_key for authorization
    IO.inspect({hostname, ipv6}, label: :DEVICE)

    device = Devices.get_device!(hostname)
    device_params = %{"ipv6" => ipv6}

    with {:ok, %Device{} = device} <- Devices.update_device(device, device_params) do
      send_resp(conn, :no_content, "")
    end
  end

  def index(conn, _params) do
    devices = Devices.list_devices()
    render(conn, :index, devices: devices)
  end

  def create(conn, %{"device" => device_params}) do
    with {:ok, %Device{} = device} <- Devices.create_device(device_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/devices/#{device}")
      |> render(:show, device: device)
    end
  end

  def show(conn, %{"id" => id}) do
    device = Devices.get_device!(id)
    render(conn, :show, device: device)
  end

  def update(conn, %{"id" => id, "device" => device_params}) do
    device = Devices.get_device!(id)

    with {:ok, %Device{} = device} <- Devices.update_device(device, device_params) do
      render(conn, :show, device: device)
    end
  end

  def delete(conn, %{"id" => id}) do
    device = Devices.get_device!(id)

    with {:ok, %Device{}} <- Devices.delete_device(device) do
      send_resp(conn, :no_content, "")
    end
  end
end
