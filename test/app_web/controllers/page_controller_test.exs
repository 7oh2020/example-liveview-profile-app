defmodule AppWeb.PageControllerTest do
  use AppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "自分のプロフィールを作成して共有してみましょう。"
  end
end
