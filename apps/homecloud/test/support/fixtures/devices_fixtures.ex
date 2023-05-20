defmodule Homecloud.DevicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Homecloud.Devices` context.
  """

  @doc """
  Generate a device.
  """
  def device_fixture(attrs \\ %{}) do
    {:ok, device} =
      attrs
      |> Enum.into(%{
        expired_at: ~U[2023-05-19 05:54:00Z],
        ipv6: "fe80::1808:a530:af1a:9b5c",
        hostname: "homecloud",
        secret_key: "xfdf7TzmTK06skGN"
      })
      |> Homecloud.Devices.create_device()

    device
  end
end
