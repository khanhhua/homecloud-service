defmodule HomecloudWeb.Files.FileJSON do
  alias Homecloud.Ftp.File
  alias Homecloud.Ftp.Directory

  @doc """
  Renders a list of files.
  """
  def index(%{files: files}) do
    %{data: for(file <- files, do: data(file))}
  end

  @doc """
  Renders a single file.
  """
  def show(%{file: file}) do
    %{data: data(file)}
  end

  defp data(%File{} = file) do
    %{
      type: "file",
      path: file.path,
      ctime: file.ctime,
      size: file.size
    }
  end

  defp data(%Directory{} = file) do
    %{
      type: "dir",
      path: file.path,
      ctime: file.ctime,
      size: file.size
    }
  end
end
