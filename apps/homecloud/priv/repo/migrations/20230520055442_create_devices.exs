defmodule Homecloud.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices, primary_key: false) do
      add :hostname, :string, primary_key: true
      add :ipv6, :string
      add :expired_at, :utc_datetime
      add :secret_key, :string

      timestamps()
    end
  end
end
