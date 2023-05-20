defmodule Homecloud.Auth do
  alias Homecloud.Auth.Login
  alias Homecloud.Ftp.Client

  @signing_salt "s@ltypepp3r"
  @token_age_secs 86_400

  @spec authenticate(term()) :: {:ok, binary()} | {:error, :unauthorized}
  def authenticate(%Login{} = login) do
    with {:ok, ipv6} <- Homecloud.Devices.resolve(login.hostname),
         # TODO username and password
         {:ok, _pid} <- Client.connect(ipv6, login.username, login.password) do
      data = %{"hostname" => login.hostname}
      # TODO pid could be use to enable security :D
      {:ok, Phoenix.Token.sign(HomecloudWeb.Endpoint, @signing_salt, data)}
    else
      e -> {:error, :unauthorized}
    end
  end

  def verify(token) do
    case Phoenix.Token.verify(HomecloudWeb.Endpoint, @signing_salt, token,
           max_age: @token_age_secs
         ) do
      {:ok, data} -> {:ok, data}
      _error -> {:error, :unauthorized}
    end
  end
end
