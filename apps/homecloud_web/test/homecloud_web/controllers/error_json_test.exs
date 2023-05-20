defmodule HomecloudWeb.ErrorJSONTest do
  use HomecloudWeb.ConnCase, async: true

  test "renders 404" do
    assert HomecloudWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert HomecloudWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
