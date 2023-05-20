defmodule HomecloudWeb.Router do
  use HomecloudWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HomecloudWeb do
    pipe_through :api

    resources "/files", Files.FileController
  end
end
