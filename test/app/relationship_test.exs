defmodule App.RelationshipTest do
  use App.DataCase

  alias App.Relationship

  describe "user_relationship" do
    alias App.Relationship.UserRelationship

    import App.RelationshipFixtures
    import App.AccountsFixtures

    test "get_user_relationship!/2 returns the user_relationship with given id" do
      u1 = user_fixture()
      u2 = user_fixture()
      rel = user_relationship_fixture(%{source_user_id: u1.id, target_user_id: u2.id})

      result = Relationship.get_user_relationship!(u1.id, u2.id)
      assert result.id == rel.id
      assert result.source_user_id == u1.id
      assert result.target_user_id == u2.id
    end

    test "create_user_relationship/1 with valid data creates a user_relationship" do
      u1 = user_fixture()
      u2 = user_fixture()

      valid_attrs = %{
        source_user_id: u1.id,
        target_user_id: u2.id
      }

      assert {:ok, %UserRelationship{}} =
               Relationship.create_user_relationship(valid_attrs)
    end

    test "delete_user_relationship/1 deletes the user_relationship" do
      u1 = user_fixture()
      u2 = user_fixture()
      rel = user_relationship_fixture(%{source_user_id: u1.id, target_user_id: u2.id})

      assert {:ok, %UserRelationship{}} = Relationship.delete_user_relationship(rel)

      assert_raise Ecto.NoResultsError, fn ->
        Relationship.get_user_relationship!(u1.id, u2.id)
      end
    end

    test "registration_change_user_relationship/3 returns a user_relationship changeset" do
      u1 = user_fixture()
      u2 = user_fixture()
      rel = user_relationship_fixture(%{source_user_id: u1.id, target_user_id: u2.id})

      assert %Ecto.Changeset{} =
               Relationship.registration_change_user_relationship(rel, u1.id, u2.id)
    end

    test "update_following_count/1 フォロー数が更新されること" do
      u1 = user_fixture()
      u2 = user_fixture()
      _rel = user_relationship_fixture(%{source_user_id: u1.id, target_user_id: u2.id})

      assert u1.following_count == 0
      assert {:ok, _} = Relationship.update_following_count(u1.id)
      assert App.Accounts.get_user!(u1.id).following_count == 1
    end

    test "update_followers_count/1 フォロワー数が更新されること" do
      u1 = user_fixture()
      u2 = user_fixture()
      _rel = user_relationship_fixture(%{source_user_id: u1.id, target_user_id: u2.id})

      assert u2.followers_count == 0
      assert {:ok, _} = Relationship.update_followers_count(u2.id)
      assert App.Accounts.get_user!(u2.id).followers_count == 1
    end

    test "list_following/1 フォローリストが取得できること" do
      u1 = user_fixture()
      u2 = user_fixture()
      _rel = user_relationship_fixture(%{source_user_id: u1.id, target_user_id: u2.id})

      assert Relationship.list_following(u1.id) == [u2]
    end

    test "list_followers/1 フォロワーリストが取得できること" do
      u1 = user_fixture()
      u2 = user_fixture()
      _rel = user_relationship_fixture(%{source_user_id: u1.id, target_user_id: u2.id})

      assert Relationship.list_followers(u2.id) == [u1]
    end
  end
end
