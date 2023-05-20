defmodule HomecloudWeb.Auth.AuthJSON do
  alias Homecloud.Auth.Session

  @doc """
  Renders a single file.
  """
  def show(%{session: session}) do
    %{data: data(session)}
  end

  defp data(%Session{} = login) do
    %{
      jwt: login.jwt
    }
  end
end
