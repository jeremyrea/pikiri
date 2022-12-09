defmodule PikiriWeb.InitAssigns do
  import Phoenix.LiveView

  alias Pikiri.Guardian

  def on_mount(:user, _params, _session, socket) do
    case get_resource(socket) do
    {:ok, resource, _claims} ->
        IO.puts(resource.email)
        {:cont, socket}
    {:error, error} ->
        IO.puts(error)
        {:cont, socket}
    end
  end

  def on_mount(:admin, _params, _session, socket) do
    case get_resource(socket) do
    {:ok, resource, _claims} ->
        case resource.role do
        "admin" -> IO.puts("Is admin")
        _ -> IO.puts("Is not admin")
        end
        {:cont, socket}
    {:error, error} ->
        IO.puts(error)
        {:cont, socket}
    end
  end

  defp get_resource(socket) do
    get_connect_params(socket)["auth_token"]
    |> Guardian.resource_from_token()
  end
end
