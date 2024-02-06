defmodule AppWeb.RelationshipLive do
  use AppWeb, :live_view

  alias App.Accounts
  alias App.Relationship

  @count_per_page 10

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <span><%= @target.email %>さんの<%= @page_title %></span>
      <:actions>
        <.link
          patch={~p"/profiles/#{@target.id}/following"}
          aria-current={@live_action == :following and "page"}
        >
          <.button>フォロー中</.button>
        </.link>
        <.link
          patch={~p"/profiles/#{@target.id}/followers"}
          aria-current={@live_action == :followers and "page"}
        >
          <.button>フォロワー</.button>
        </.link>
      </:actions>
    </.header>
    <div id="users" phx-update="stream">
      <article :for={{dom_id, user} <- @streams.users} id={dom_id}>
        <.link navigate={~p"/profiles/#{user}"}>
          <h3><%= user.email %></h3>
        </.link>
      </article>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(target: Accounts.get_user!(id))
     |> stream(:users, [], limit: @count_per_page)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :following, %{"id" => id}) do
    socket
    |> assign(page_title: "フォロー中リスト")
    |> stream(:users, Relationship.list_following(id), limit: @count_per_page, reset: true)
  end

  defp apply_action(socket, :followers, %{"id" => id}) do
    socket
    |> assign(page_title: "フォロワーリスト")
    |> stream(:users, Relationship.list_followers(id), limit: @count_per_page, reset: true)
  end
end
