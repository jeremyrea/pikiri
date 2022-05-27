defmodule PikiriWeb.InitAssigns do
  import Phoenix.LiveView

  def on_mount(:user, params, session, socket) do
    auth_token = get_connect_params(socket)["auth_token"]
    case Pikiri.Guardian.resource_from_token(auth_token) do
    {:ok, resource, claims} -> 
        IO.puts(resource.email)
        {:cont, socket}
    {:error, error} ->
        IO.puts(error) 
        {:cont, socket}
    end
  end

  def on_mount(:admin, params, session, socket) do
    auth_token = get_connect_params(socket)["auth_token"]
    case Pikiri.Guardian.resource_from_token(auth_token) do
    {:ok, resource, claims} -> 
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
end