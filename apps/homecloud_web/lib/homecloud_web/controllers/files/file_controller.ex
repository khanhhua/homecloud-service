defmodule HomecloudWeb.Files.FileController do
  use HomecloudWeb, :controller

  alias Homecloud.Ftp.Client

  action_fallback HomecloudWeb.FallbackController

  def index(conn, _params) do
    files =
      if Client.is_connected?("localhost") do
        Client.client!("localhost")
        |> Client.dir("/")
      else
        with {:ok, client} <- Client.connect("localhost") do
          Client.dir(client, "/")
        end
      end

    render(conn, :index, files: files)
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
