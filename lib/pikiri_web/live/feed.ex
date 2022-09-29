defmodule PikiriWeb.Live.Feed do
  use PikiriWeb, :live_view

  alias Pikiri.Posts
  alias Pikiri.Users
  alias Pikiri.Uploaders.PhotoUploader

  def render(assigns) do
    ~H"""
    <div class="feed">
      <table>
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
            <.live_component module={UploadComponent} id="upload" uploads={@uploads} show={@show_upload_modal} />
          </li>
        </ul>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign(:cursor, DateTime.utc_now)
     |> assign(:per_page, 1)
     |> assign(:update_method, "append")
     |> assign(:uploaded_files, [])
     |> assign(:show_upload_modal, false)
     |> assign(:current_user, session["user_id"])
     |> allow_upload(:photo, accept: ~w(.jpg .jpeg .png), max_entries: 1)
     |> fetch(), temporary_assigns: [posts: []]}
  end

  defp fetch(%{assigns: %{cursor: date_from, per_page: take}} = socket) do
    user_id = socket.assigns.current_user
    socket
    |> assign(:posts, Posts.get_posts(date_from, take, user_id))
    |> assign(:update_method, "append")
  end

  def handle_event("load-more", %{"cursor" => cursor}, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(cursor: cursor) |> fetch()}
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
  def handle_event("save", _params, socket) do
  user_id = socket.assigns.current_user
    uploaded_files =
      consume_uploaded_entries(socket, :photo, fn %{path: path}, entry ->
        [file_extension | _] = MIME.extensions(entry.client_type)
        file_name = "#{entry.uuid}.#{file_extension}"
        dest = Path.join([PhotoUploader.storage_dir, file_name])

        File.cp!(path, dest)
        {:ok, dest}
      end)

    [new_file | _] = uploaded_files

    {:ok, binary} = File.read(new_file)
    content = %{
      photo: %{
        filename: Path.basename(new_file),
        binary: binary
      }
    }

    result = Posts.create_post(%{user_id: user_id, content: content})

    case result do
      {:ok, new_post} ->
        {:noreply,
          socket
          |> assign(show_upload_modal: false)
          |> assign(:uploaded_files, [])
          |> assign(:update_method, "prepend")
          |> update(:posts, fn posts -> [new_post | posts] end)}
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

    {:noreply, socket |> update(:posts, fn posts -> [updated_post] end)}
  end
end
