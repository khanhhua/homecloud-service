defmodule HomecloudWeb.Files.FileController do
  use HomecloudWeb, :controller

  alias Homecloud.Devices
  alias Homecloud.Ftp.Client

  action_fallback HomecloudWeb.FallbackController

  def index(%Plug.Conn{assigns: %{current_hostname: hostname}} = conn, _params) do
    with {:ok, ipv6} <- Devices.resolve(hostname) do
      IO.puts("Connecting to #{:inet.ntoa(ipv6)}...")

      if Client.is_connected?(ipv6) do
        files =
          Client.client!(ipv6)
          |> Client.dir("/")

        render(conn, :index, files: files)
      else
        send_resp(conn, 401, "Unauthorized")
      end
    else
      e ->
        send_resp(conn, 400, "Could not resolve hostname: #{hostname}")
    end
  end

  # def create(conn, %{"file" => file_params}) do
  #   with {:ok, %File{} = file} <- Files.create_file(file_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", ~p"/api/files/files/#{file}")
  #     |> render(:show, file: file)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   file = Files.get_file!(id)
  #   render(conn, :show, file: file)
  # end

  # def update(conn, %{"id" => id, "file" => file_params}) do
  #   file = Files.get_file!(id)

  #   with {:ok, %File{} = file} <- Files.update_file(file, file_params) do
  #     render(conn, :show, file: file)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   file = Files.get_file!(id)

  #   with {:ok, %File{}} <- Files.delete_file(file) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
