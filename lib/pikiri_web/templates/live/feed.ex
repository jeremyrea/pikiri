defmodule PikiriWeb.Live.Feed do
  use Phoenix.LiveView
#   alias PikiriWeb.UserLive.Row

  def render(assigns) do
    ~L"""
    <table>
      <tbody id="users" phx-update="append">
        <%= for user <- @users do %>
          <tr id=<%= user %>>
            <td><%= user %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    <div id="InfiniteScroll" phx-hook="InfiniteScroll" data-page="<%= @page %>"></div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page: 1, per_page: 50)
     |> fetch(), temporary_assigns: [users: []]}
  end

  defp fetch(%{assigns: %{page: page, per_page: per}} = socket) do
    values = List.duplicate(nil, per) 
    |> Enum.with_index 
    |> Enum.map fn {k,v} -> v+(50*(page-1)) end

    assign(socket, users: values)
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
  end
end