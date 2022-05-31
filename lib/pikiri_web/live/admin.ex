defmodule PikiriWeb.Live.Admin do
  use PikiriWeb, :live_view

  alias Pikiri.Users
  alias Pikiri.Users.User

  @roles [
    "#{gettext("Viewer")}": "viewer", 
    "#{gettext("Contributor")}": "contributor",
    "#{gettext("Admin")}": "admin"
  ]

  def render(assigns) do
    ~H"""
    <div class="users">
      <.form let={f} for={@invitation} phx-submit="invite" class="user-add">
        <%= text_input f, :email, [placeholder: gettext("email")] %>
        <%= submit gettext("Add user") %>
      </.form>
      <table class="user-list">
        <thead>
          <tr>
            <th><%= gettext("Email") %></th>
            <th><%= gettext("Status") %></th>
            <th><%= gettext("Role") %></th>
          </tr>
        </thead>
        <tbody id="users" phx-update="append">
          <%= for user <- @users do %>
            <tr id="#{user.uuid}">
              <td data-th={gettext("Email")}>
                <div><%= user.email %></div>
              </td>
              <td data-th={gettext("Status")}>
                <div><%= user.status %></div>
              </td>
              <td data-th={gettext("Role")}>
                <form phx-change="role_changed">
                <input name="uuid" value={user.uuid} hidden="true" />
                <select name="role" id="select_role">
                  <%= for {role_label, role_key} <- @roles do %>
                    <option value={role_key} selected={selected_attr(user.role, role_key)}>
                      <%= role_label %>
                    </option>
                  <% end %>
                  </select>
                </form>
              <td class="separator" colspan="2">
                <div></div>
              </td>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket 
     |> assign(roles: @roles) 
     |> assign(users: Users.list_users())
     |> assign(invitation: User.changeset(%User{}))}
  end

  def handle_event("invite", user_changeset, socket) do
    IO.inspect(user_changeset)
    {:ok, user} = Users.create_user(user_changeset["user"])
    {:ok, _magic_token, _claims} = Pikiri.Guardian.send_magic_link(user)
    updated_users = [ user | socket.assigns.users ]

    {:noreply, assign(socket, users: updated_users)}
  end

  def handle_event("role_changed", %{"uuid" => uuid, "role" => role, "_target" => _target}, socket) do
    {:ok, user} = uuid |> Users.get_user |> Users.set_role(role)
    
    users = socket.assigns.users
    index = users |> Enum.find_index(fn u -> u.id == user.id end)
    updated_users = List.replace_at(users, index, user)
    
    {:noreply, assign(socket, users: updated_users)}
  end

  defp selected_attr(role, role), do: true
  defp selected_attr(_, _), do: false
end