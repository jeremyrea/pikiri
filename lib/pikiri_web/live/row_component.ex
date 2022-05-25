defmodule RowComponent do
  use PikiriWeb, :live_component

  def render(assigns) do
    ~H"""
    <tr id={"#{@id}"}>
      <td>
          <%= render_slot(@inner_block) %>
          <img src={"/images/dataset/#{@user}.jpg"} style="max-height: 200px" />
      </td>
    </tr>
    """
  end
end