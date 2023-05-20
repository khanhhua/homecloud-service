defmodule Homecloud.FilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Homecloud.Files` context.
  """

  @doc """
  Generate a file.
  """
  def file_fixture(attrs \\ %{}) do
    {:ok, file} =
      attrs
      |> Enum.into(%{})
      |> Homecloud.Files.create_file()

    file
  end
end
