defmodule AppWeb.ProfileLiveTest do
  use AppWeb.ConnCase, async: true

  setup :register_and_log_in_user

  import Phoenix.LiveViewTest
  import App.AccountsFixtures
  import App.RelationshipFixtures

  describe "index" do
    test "フォローができること", %{conn: conn, user: user} do
      target = user_fixture()

      # 相手のプロフィールページへ移動し、フォローボタンをクリックする
      {:ok, lv, html} = live(conn, ~p"/profiles/#{target}")
      assert html =~ "0 フォロワー"

      html =
        lv
        |> element("button", "フォローする")
        |> render_click()

      assert html =~ "フォロー解除"
      assert html =~ "フォローしました"
      assert html =~ "1 フォロワー"

      # 自分のプロフィールページへ移動する
      {:ok, _lv, html} = live(conn, ~p"/profiles/#{user}")
      assert html =~ "1 フォロー"
    end

    test "フォロー解除ができること", %{conn: conn, user: user} do
      target = user_fixture()
      _rel = user_relationship_fixture(%{source_user_id: user.id, target_user_id: target.id})
      assert {:ok, _} = App.Relationship.update_following_count(user.id)
      assert {:ok, _} = App.Relationship.update_followers_count(target.id)

      # 相手のプロフィールページへ移動し、フォロー解除ボタンをクリックする
      {:ok, lv, html} = live(conn, ~p"/profiles/#{target}")
      assert html =~ "1 フォロワー"

      html =
        lv
        |> element("button", "フォロー解除")
        |> render_click()

      assert html =~ "フォローする"
      assert html =~ "フォローを解除しました"
      assert html =~ "0 フォロワー"

      # 自分のプロフィールページへ移動する
      {:ok, _lv, html} = live(conn, ~p"/profiles/#{user}")
      assert html =~ "0 フォロー"
    end
  end
end
