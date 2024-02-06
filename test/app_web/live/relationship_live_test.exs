defmodule AppWeb.RelationshipLiveTest do
  use AppWeb.ConnCase, async: true

  setup :register_and_log_in_user

  import Phoenix.LiveViewTest
  import App.AccountsFixtures
  import App.RelationshipFixtures

  describe "index" do
    test "フォローリストが表示できること", %{conn: conn, user: user} do
      target = user_fixture()
      _rel = user_relationship_fixture(%{source_user_id: user.id, target_user_id: target.id})

      {:ok, _lv, html} = live(conn, ~p"/profiles/#{user}/following")
      assert html =~ "#{user.email}さんのフォロー中リスト"
      assert html =~ target.email
    end

    test "フォロワーリストが表示できること", %{conn: conn, user: user} do
      target = user_fixture()
      _rel = user_relationship_fixture(%{source_user_id: user.id, target_user_id: target.id})

      {:ok, _lv, html} = live(conn, ~p"/profiles/#{target}/followers")
      assert html =~ "#{target.email}さんのフォロワーリスト"
      assert html =~ user.email
    end
  end
end
