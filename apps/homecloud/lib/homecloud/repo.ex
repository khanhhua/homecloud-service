defmodule Homecloud.Repo do
  use Ecto.Repo,
    otp_app: :homecloud,
    adapter: Ecto.Adapters.Postgres
end
