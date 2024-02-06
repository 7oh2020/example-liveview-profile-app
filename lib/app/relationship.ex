defmodule App.Relationship do
  @moduledoc """
  The Relationship context.
  """

  import Ecto.Query, warn: false

  alias App.Repo

  alias App.Relationship.UserRelationship
  alias App.Accounts
  alias App.Accounts.User

  @count_of_page 10

  @doc """
  フォローリストを取得します。

  ## Options

  - limit
  - offset
  """
  def list_following(id, opts \\ []) do
    limit = Keyword.get(opts, :limit, @count_of_page)
    offset = Keyword.get(opts, :offset, 0)

    query =
      from(
        r in UserRelationship,
        where: r.source_user_id == ^id,
        join: u in assoc(r, :target_user),
        select: u,
        order_by: [desc: r.inserted_at],
        limit: ^limit,
        offset: ^offset
      )

    Repo.all(query)
  end

  @doc """
  フォロワーリストを取得します。

  ## Options

  - limit
  - offset
  """
  def list_followers(id, opts \\ []) do
    limit = Keyword.get(opts, :limit, @count_of_page)
    offset = Keyword.get(opts, :offset, 0)

    query =
      from(
        r in UserRelationship,
        where: r.target_user_id == ^id,
        join: u in assoc(r, :source_user),
        select: u,
        order_by: [desc: r.inserted_at],
        limit: ^limit,
        offset: ^offset
      )

    Repo.all(query)
  end

  @doc """
  条件にマッチするリレーションシップを1つ取得します。見つからない場合はnilを返します。
  """
  def get_user_relationship(source_user_id, target_user_id),
    do: Repo.one(get_relationship_query(source_user_id, target_user_id))

  @doc """
  条件にマッチするリレーションシップを1つ取得します。見つからない場合は`Ecto.NoResultsError`をraiseします。
  """
  def get_user_relationship!(source_user_id, target_user_id),
    do: Repo.one!(get_relationship_query(source_user_id, target_user_id))

  defp get_relationship_query(source_user_id, target_user_id) do
    from(
      r in UserRelationship,
      where: r.source_user_id == ^source_user_id and r.target_user_id == ^target_user_id
    )
  end

  @doc """
  リレーションシップを作成します。
  """
  def create_user_relationship(attrs \\ %{}) do
    source_user_id = Map.get(attrs, :source_user_id) || Map.get(attrs, "source_user_id")
    target_user_id = Map.get(attrs, :target_user_id) || Map.get(attrs, "target_user_id")

    %UserRelationship{}
    |> registration_change_user_relationship(source_user_id, target_user_id, attrs)
    |> Repo.insert()
  end

  @doc """
  リレーションシップを削除します。
  """
  def delete_user_relationship(%UserRelationship{} = user_relationship) do
    Repo.delete(user_relationship)
  end

  @doc false
  def registration_change_user_relationship(
        %UserRelationship{} = user_relationship,
        source_user_id,
        target_user_id,
        attrs \\ %{}
      ) do
    user_relationship
    |> UserRelationship.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:source_user, App.Accounts.get_user!(source_user_id))
    |> Ecto.Changeset.put_assoc(:target_user, App.Accounts.get_user!(target_user_id))
  end

  @doc """
  フォロー数を更新します。
  """
  def update_following_count(id) do
    query = from(r in UserRelationship, where: r.source_user_id == ^id)
    count = Repo.aggregate(query, :count, :id)
    user = Accounts.get_user!(id)

    {:ok, _} =
      user
      |> User.following_count_changeset(%{following_count: count})
      |> Repo.update()
  end

  @doc """
  フォロワー数を更新します。
  """
  def update_followers_count(id) do
    query = from(r in UserRelationship, where: r.target_user_id == ^id)
    count = Repo.aggregate(query, :count, :id)
    user = Accounts.get_user!(id)

    {:ok, _} =
      user
      |> User.followers_count_changeset(%{followers_count: count})
      |> Repo.update()
  end
end
