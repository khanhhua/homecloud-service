defmodule HomecloudWeb.Auth.AuthController do
  use HomecloudWeb, :controller

  alias Homecloud.Devices
  alias Homecloud.Devices.Device
  alias Homecloud.Ftp.Client

  alias Homecloud.Auth
  alias Homecloud.Auth.Login
  alias Homecloud.Auth.Session

  action_fallback HomecloudWeb.FallbackController

  def login(
        conn,
        %{"hostname" => hostname, "username" => username, "password" => password} = login
      ) do
    IO.inspect(login, label: LOGIN)

    {:ok, jwt} =
      Auth.authenticate(%Login{hostname: hostname, username: username, password: password})

    render(conn, :show, session: %Session{jwt: jwt})
  end
end
