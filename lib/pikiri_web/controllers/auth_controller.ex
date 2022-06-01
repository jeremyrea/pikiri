defmodule PikiriWeb.AuthController do
  use PikiriWeb, :controller
  import Plug.Conn

  alias PikiriWeb.Router.Helpers, as: Routes
  alias Pikiri.Users
  alias Pikiri.Guardian

  def index(conn, params) do
    magic_token = params |> Map.get("token")
    case Guardian.exchange_magic(magic_token) do
    {:ok, access_token, claims} ->
        case Guardian.resource_from_claims(claims) do
        {:ok, user} -> Users.set_status(user, "confirmed")
        {:error, :not_found} -> IO.puts("User not found from magic token")
        end 

        ops = [
          sign: false, 
          http_only: false, 
          same_site: "strict"
        ]
        put_resp_cookie(conn, "pikiri_auth_token", access_token, ops)
        |> Phoenix.Controller.redirect(to: Router.get_route)
        |> Plug.Conn.halt()
    {:error, _error} ->
        conn
        |> Phoenix.Controller.redirect(to: Routes.login_path(conn, :new))
        |> Plug.Conn.halt()
    end
  end
end
