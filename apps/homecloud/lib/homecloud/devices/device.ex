defmodule Homecloud.Devices.Device do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:hostname, :string, []}
  schema "devices" do
    field :secret_key, :string
    field :expired_at, :utc_datetime
    field :ipv6, :string

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:hostname, :ipv6, :secret_key, :expired_at])
    |> validate_required([:hostname, :secret_key])
  end
end
