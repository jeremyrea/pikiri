defmodule UploadComponent do
  use PikiriWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="upload">
      <form id="upload-form" phx-submit="save" phx-change="validate">
        <div class="upload-button" id="open-modal" phx-hook="ModalControl" data-action="open" data-modal-id="upload">
          <label id="upload-trigger"><FontAwesome.LiveView.icon name="camera-retro" /></label>
        </div>
        <%= if @show do %>
          <div class="preview">
            <figure>
              <%= live_file_input @uploads.photo, class: "upload-input center" %>
              <%= for entry <- @uploads.photo.entries do %>
                <progress value={entry.progress} max="100" class="upload-progress center"> <%= entry.progress %>% </progress>
                <%= live_img_preview entry, class: "center" %>
                <%= for err <- upload_errors(@uploads.photo, entry) do %>
                  <p class="alert alert-danger"><%= error_to_string(err) %></p>
                <% end %>
              <% end %>
            </figure>
            <button type="submit">Submit</button>
            <button phx-click="cancel-upload" phx-value-ref={get_ref(@uploads.photo.entries)}>Cancel</button>
          </div>
        <% end %>          
        <%= for err <- upload_errors(@uploads.photo) do %>
          <p class="alert alert-danger"><%= error_to_string(err) %></p>
        <% end %>
      </form>
    </div>
    """
  end

  # Cancel does not work for some reason
  defp get_ref(entries) do
    case List.first(entries) do
      nil -> nil
      entry -> entry.ref |> IO.puts
    end
  end

  defp error_to_string(:too_large), do: gettext("Too large")
  defp error_to_string(:too_many_files), do: gettext("You have selected too many files")
  defp error_to_string(:not_accepted), do: gettext("You have selected an unacceptable file type")
end