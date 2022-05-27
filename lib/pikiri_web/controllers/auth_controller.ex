defmodule PikiriWeb.AuthController do
  use PikiriWeb, :controller
  import Plug.Conn

  def index(conn, params) do
    magic_token = params |> Map.get("token")
    case Pikiri.Guardian.exchange_magic(magic_token) do
    {:ok, access_token, _claims} -> 
        put_resp_cookie(conn, "pikiri_auth_token", access_token, sign: false, http_only: false, same_site: "strict")
        |> Phoenix.Controller.redirect(to: "/")
        |> Plug.Conn.halt()
    {:error, :invalid_token} ->
        # Redirect and halt
        conn
        |> Phoenix.Controller.redirect(to: "/")
        |> Plug.Conn.halt()
    {:error, :token_expired} ->
        # Redirect and halt
        conn
        |> Phoenix.Controller.redirect(to: "/")
        |> Plug.Conn.halt()
    end
  end
end
