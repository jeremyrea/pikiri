defmodule RowComponent do
  use PikiriWeb, :live_component
  import PolymorphicEmbed

  alias Pikiri.Uploaders.PhotoUploader

  def render(assigns) do
    ~H"""
    <tr id={"#{@post.id}"} class="card">
      <td>
          <%= render_slot(@inner_block) %>
          <%= case get_polymorphic_type(Pikiri.Posts.Post, :content, @post.content) do %>
            <% :image -> %>
              <%= case @post.content.photo do %>
                <% nil -> %>
                  <span>No image</span>
                <% _ -> %>
                  <picture>
                    <source srcset={image_path(@post.content, :avif)} type="image/avif" loading="lazy" oncontextmenu="return false;" />
                    <source srcset={image_path(@post.content, :jxl)} type="image/jxl" loading="lazy" oncontextmenu="return false;" />
                    <source srcset={image_path(@post.content, :webp)} type="image/webp" loading="lazy" oncontextmenu="return false;" />
                    <img src={image_path(@post.content, :jpeg)} loading="lazy" oncontextmenu="return false;" />
                  </picture>
              <%end%>
            <% :text -> %>
              <% @post.content.text %>
          <%end%>
          <div class="timestamp">
            <%= @post.inserted_at |> Calendar.strftime("%d-%m-%Y") %>
          </div>
          <div phx-click="toggle-like" phx-value-post_id={@post.id} phx-value-liked={if @post.liked, do: 1, else: 0}>
            <FontAwesome.LiveView.icon name="heart" type={if @post.liked, do: "solid", else: "regular"} class={"like #{if @post.liked, do: 'liked'}"} />
          </div>
          <div class="caption" style={"rotate: #{@post.content.caption_rotation}deg"}>
            <%= @post.content.caption %>
          </div>
      </td>
    </tr>
    """
  end

  defp image_path(post, format) do
    PhotoUploader.url({post.photo.file_name, post}, format)
  end
end
