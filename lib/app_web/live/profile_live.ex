defmodule AppWeb.ProfileLive do
  use AppWeb, :live_view

  alias App.Accounts
  alias App.Accounts.User
  alias App.Relationship

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <h1><%= @target.email %></h1>
      <:actions :if={@show_follow}>
        <.button :if={!@is_following} phx-click="follow" phx-value-id={@target.id}>
          フォローする
        </.button>
        <.button :if={@is_following} phx-click="unfollow" phx-value-id={@target.id}>
          フォロー解除
        </.button>
      </:actions>
    </.header>
    <div class="flex gap-4 py-2">
      <div class="p-2">
        <.link navigate={~p"/profiles/#{@target}/following"}>
          <%= @target.following_count %> フォロー
        </.link>
      </div>
      <div class="p-2">
        <.link navigate={~p"/profiles/#{@target}/followers"}>
          <%= @followers_count %> フォロワー
        </.link>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    source = socket.assigns.current_user
    target = Accounts.get_user!(id)
    rel = Relationship.get_user_relationship(source.id, target.id)

    {:ok,
     socket
     |> assign(target: target)
     |> assign(page_title: "#{target.email}さんのプロフィール")
     |> assign(show_follow: source.id != target.id)
     |> assign(is_following: !is_nil(rel))
     |> assign(followers_count: target.followers_count)}
  end

  @impl true
  def handle_event("follow", %{"id" => target_id}, socket) do
    attrs = %{
      source_user_id: socket.assigns.current_user.id,
      target_user_id: target_id
    }

    with {:ok, _} <- Relationship.create_user_relationship(attrs),
         {:ok, _} <- Relationship.update_following_count(attrs.source_user_id),
         {:ok, %User{followers_count: followers_count}} <-
           Relationship.update_followers_count(attrs.target_user_id) do
      {:noreply,
       socket
       |> assign(is_following: true)
       |> assign(followers_count: followers_count)
       |> put_flash(:info, "フォローしました")}
    else
      _ -> {:noreply, put_flash(socket, :error, "フォローの途中でエラーが発生しました")}
    end
  end

  @impl true
  def handle_event("unfollow", %{"id" => target_id}, socket) do
    rel = Relationship.get_user_relationship!(socket.assigns.current_user.id, target_id)

    with {:ok, _} <- Relationship.delete_user_relationship(rel),
         {:ok, _} <- Relationship.update_following_count(rel.source_user_id),
         {:ok, %User{followers_count: followers_count}} <-
           Relationship.update_followers_count(rel.target_user_id) do
      {:noreply,
       socket
       |> assign(is_following: false)
       |> assign(followers_count: followers_count)
       |> put_flash(:info, "フォローを解除しました")}
    else
      _ -> {:noreply, put_flash(socket, :error, "フォロー解除の途中でエラーが発生しました")}
    end
  end
end
