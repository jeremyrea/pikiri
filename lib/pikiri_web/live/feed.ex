defmodule PikiriWeb.Live.Feed do
  use PikiriWeb, :live_view

  alias Pikiri.Posts

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @new_posts_available do %>
      <div class="toast">
        <%= gettext("New post available!") %>
        <div>
          <span phx-click="user-reload" phx-value-ignore="0">
            <%= gettext("View") %>
          </span>
          <span phx-click="user-reload" phx-value-ignore="1">
            <%= gettext("Dismiss") %>
          </span>
        </div>
      </div>
    <% end %>
    <div class="feed">
      <table style={"visibility: #{if @show_upload_modal, do: 'hidden', else: 'revert'}"}>
        <tbody id="photos" phx-update={@update_method}>
          <%= for {post, index} <- Enum.with_index(@posts) do %>
            <.live_component module={RowComponent} id={post.id} post={post}>
              <%= if index == length(@posts) - 1 do %>
                <div id="InfiniteScroll" phx-hook="InfiniteScroll" data-cursor={post.inserted_at}></div>
              <% end %>
            </.live_component>
          <% end %>
        </tbody>
      </table>
      <div class="actions">
        <ul>
          <li>
            <.live_component module={UploadComponent} id="upload" uploads={@uploads} changeset={@changeset} show={@show_upload_modal} />
          </li>
        </ul>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Pikiri.PubSub, "new_post")

    {:ok,
     socket
     |> assign(:cursor, DateTime.utc_now)
     |> assign(:per_page, 10)
     |> assign(:update_method, "append")
     |> assign(:uploaded_files, [])
     |> assign(:show_upload_modal, false)
     |> assign(:new_posts_available, false)
     |> assign(:current_user, session["user_id"])
     |> assign(:mask, %{})
     |> assign(:changeset, Posts.Post.changeset(%Posts.Post{}))
     |> allow_upload(:photo, accept: ~w(.jpg .jpeg .png), max_entries: 1)
     |> fetch(), temporary_assigns: [posts: []]}
  end

  defp fetch(%{assigns: %{cursor: date_from, per_page: take}} = socket) do
    user_id = socket.assigns.current_user
    socket
    |> assign(:posts, Posts.get_posts(date_from, take, user_id))
    |> assign(:update_method, "append")
  end

  @impl true
  def handle_info({:new_post, %{user_id: uploader_id, post_id: post_id}} = _info, socket) do
    user_id = socket.assigns.current_user
    new_post = Posts.get_post(post_id, user_id)

    {:noreply,
    socket
    |> assign(:new_posts_available, (uploader_id != user_id) || socket.assigns.new_posts_available)
    |> assign(:update_method, "prepend")
    |> update(:posts, fn posts -> [new_post | posts] end)
  }
  end

  def handle_event("user-reload", %{"ignore" => str_ignore}, socket) do
    case str_ignore do
      "1" -> {:noreply, socket |> assign(:new_posts_available, false)}
      "0" ->
        {
          :noreply,
          socket
          |> assign(:new_posts_available, false)
          |> push_event("scroll-to-top", %{})
        }
    end
  end

  def handle_event("load-more", %{"cursor" => cursor}, %{assigns: _assigns} = socket) do
    {:noreply, socket |> assign(cursor: cursor) |> fetch()}
  end

  def handle_event("update-mask", %{"value" => value}, %{assigns: _assigns} = socket) do
    {:noreply, socket |> assign(mask: value)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply,
    socket
    |> assign(show_upload_modal: false)
    |> cancel_upload(:photo, ref)}
  end
  def handle_event("cancel-upload", %{}, socket) do
    {:noreply, socket |> assign(show_upload_modal: false)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"post" => %{"caption" => caption}}, socket) do
    user_id = socket.assigns.current_user
    uploaded_files =
      consume_uploaded_entries(socket, :photo, fn %{path: path}, entry ->
        [file_extension | _] = MIME.extensions(entry.client_type)
        file_name = "#{Ulid.generate()}.#{file_extension}"

        dest = Path.join([System.tmp_dir!(), file_name])

        File.cp!(path, dest)
        {:ok, dest}
      end)

    [new_file | _] = uploaded_files

    {:ok, binary} = File.read(new_file)

    content = %{
      photo: %{
        filename: Path.basename(new_file),
        binary: binary
      },
      mask: socket.assigns.mask,
      caption: caption
    }

    result = Posts.create_post(%{user_id: user_id, content: content})

    case result do
      {:ok, new_post} ->
        Phoenix.PubSub.broadcast(Pikiri.PubSub, "new_post", {:new_post, %{user_id: user_id, post_id: new_post.id}})
        {:noreply,
          socket
          |> assign(show_upload_modal: false)
          |> assign(:uploaded_files, [])}
      {:error, changeset} ->
        IO.inspect changeset
        {:noreply,
        socket
        |> assign(show_upload_modal: false)}
    end
  end

  def handle_event("open-upload-modal", _params, socket) do
    {:noreply, socket |> assign(show_upload_modal: true)}
  end

  def handle_event("toggle-like", %{"post_id" => str_post_id, "liked" => str_liked}, socket) do
    user_id = socket.assigns.current_user
    post_id = String.to_integer(str_post_id)
    liked = if String.to_integer(str_liked) == 0, do: false, else: true

    case liked do
      true -> Posts.unlike_post(user_id, post_id)
      false -> Posts.like_post(user_id, post_id)
    end

    updated_post = Posts.get_post(post_id, user_id)

    {:noreply, socket |> update(:posts, fn _posts -> [updated_post] end)}
  end
end
