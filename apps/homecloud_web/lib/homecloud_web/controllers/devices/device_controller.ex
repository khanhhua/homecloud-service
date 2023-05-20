defmodule HomecloudWeb.Devices.DeviceController do
  use HomecloudWeb, :controller

  alias Homecloud.Devices
  alias Homecloud.Devices.Device

  action_fallback HomecloudWeb.FallbackController

  def advertise(conn, %{"device" => %{"hostname" => hostname, "ipv6" => ipv6}}) do
    # TODO Header must include the secret_key for authorization
    with [secret_key] <- get_req_header(conn, "x-secret-key") do
      # IO.inspect({hostname, ipv6, secret_key}, label: :DEVICE)
      device = Devices.get_device!(hostname)
      if device.secret_key != secret_key do
        send_resp(conn, :not_found, "Not Found")
      else
        device_params = %{"ipv6" => ipv6}

        with {:ok, %Device{}} <- Devices.update_device(device, device_params) do
          send_resp(conn, 200, "")
        end
      end
    else
      _ -> send_resp(conn, 400, "Bad Request")
    end
  end

  def index(conn, _params) do
    devices = Devices.list_devices()
    render(conn, :index, devices: devices)
  end

  def create(conn, %{"device" => device_params}) do
    # TODO Further means of authorization should be thought of
    # It could be a invitate token or a authcode or phone number or email or Google Robot check
    with {:ok, %Device{} = device} <- Devices.create_device(%{"secret_key" => Devices.generate_secret_key()} |> Enum.into(device_params)) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/devices/#{device.hostname}")
      |> render(:show_on_create, device: device)
    end
  end

  def show(conn, %{"id" => hostname}) do
    device = Devices.get_device!(hostname)
    render(conn, :show, device: device)
  end

  def update(conn, %{"id" => hostname, "device" => device_params}) do
    device = Devices.get_device!(hostname)

    with {:ok, %Device{} = device} <- Devices.update_device(device, device_params) do
      render(conn, :show, device: device)
    end
  end

  def delete(conn, %{"id" => hostname}) do
    device = Devices.get_device!(hostname)

    with {:ok, %Device{}} <- Devices.delete_device(device) do
      send_resp(conn, :no_content, "")
    end
  end
end
