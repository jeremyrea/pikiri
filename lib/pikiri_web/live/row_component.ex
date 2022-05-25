defmodule RowComponent do
  use PikiriWeb, :live_component

  def render(assigns) do
    ~H"""
    <tr id={"#{@id}"} class="card">
      <td>
          <%= render_slot(@inner_block) %>
          <img src={"/images/dataset/#{@user}.jpg"} />
      </td>
    </tr>
    """
  end
end