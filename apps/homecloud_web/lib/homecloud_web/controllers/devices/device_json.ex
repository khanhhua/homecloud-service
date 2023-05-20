defmodule HomecloudWeb.Devices.DeviceJSON do
  alias Homecloud.Devices.Device

  @doc """
  Renders a list of devices.
  """
  def index(%{devices: devices}) do
    %{data: for(device <- devices, do: data(device))}
  end

  @doc """
  Renders a single device.
  """
  def show(%{device: device}) do
    %{data: data(device)}
  end

  def show_on_create(%{device: device}) do
    %{
      data: %{secret_key: device.secret_key} |> Enum.into(data(device))
    }
  end

  defp data(%Device{} = device) do
    %{
      hostname: device.hostname,
      ipv6: device.ipv6,
      expired_at: device.expired_at
    }
  end
end
