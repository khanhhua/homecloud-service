defmodule Homecloud.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Homecloud.Repo,
      # Start the PubSub system
      # {Phoenix.PubSub, name: Homecloud.PubSub}
      # Start a worker by calling: Homecloud.Worker.start_link(arg)
      # {Homecloud.Worker, arg}
      {DynamicSupervisor, name: Homecloud.Ftp.Supervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Homecloud.Supervisor)
  end
end
