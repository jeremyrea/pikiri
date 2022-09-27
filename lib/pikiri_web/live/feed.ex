defmodule PikiriWeb.Live.Feed do
  use PikiriWeb, :live_view

  alias Pikiri.Posts
  alias Pikiri.Users

  def render(assigns) do
    ~H"""
    <div class="feed">
      <table>
        <tbody id="photos" phx-update="append">
          <%= for {post, index} <- Enum.with_index(@posts) do %>
            <.live_component module={RowComponent} id={post.id} post={post}>
              <%= if index == length(@posts) - 1 do %>
                <div id="InfiniteScroll" phx-hook="InfiniteScroll" data-page={@page}></div>
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
     |> assign(page: 1, per_page: 5)
     |> assign(:uploaded_files, [])
     |> assign(:show_upload_modal, false)
     |> assign(:current_user, session["user_id"])
     |> allow_upload(:photo, accept: ~w(.jpg .jpeg .png), max_entries: 1)
     |> fetch(), temporary_assigns: [posts: []]}
  end

  defp fetch(%{assigns: %{page: page, per_page: take}} = socket) do
    # values = List.duplicate(nil, per) 
    # |> Enum.with_index 
    # |> Enum.map(fn {_k,v} -> v+(5*(page-1)) end)
    posts = Posts.get_posts(DateTime.utc_now, take)

    socket
    |> assign(:posts, posts)
  end

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
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
        file_extension = MIME.extensions(entry.client_type)
        file_name = "#{entry.uuid}.#{file_extension}"
        dest = Path.join([:code.priv_dir(:pikiri), "static", "uploads", file_name])
  
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
end