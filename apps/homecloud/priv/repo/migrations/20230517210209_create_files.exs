defmodule Homecloud.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files) do

      timestamps()
    end
  end
end
