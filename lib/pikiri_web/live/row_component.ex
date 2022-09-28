defmodule RowComponent do
  use PikiriWeb, :live_component
  import PolymorphicEmbed

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
                  <img src={"/uploads/posts/#{@post.content.photo.file_name}"} oncontextmenu="return false;" />
              <%end%>
            <% :text -> %>
              <% @post.content.text %>
          <%end%>
      </td>
    </tr>
    """
  end
end
