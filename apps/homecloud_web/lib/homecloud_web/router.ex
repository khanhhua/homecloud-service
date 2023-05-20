defmodule HomecloudWeb.Router do
  use HomecloudWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :hostname_specific do
    plug HomecloudWeb.PlugAuthenticate
  end

  scope "/api", HomecloudWeb do
    pipe_through [:api, :hostname_specific]

    resources "/files", Files.FileController
  end

  scope "/api", HomecloudWeb do
    pipe_through :api

    resources "/devices", Devices.DeviceController

    post "/login", Auth.AuthController, :login
    post "/advertise", Devices.DeviceController, :advertise
  end
end
