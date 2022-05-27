defmodule PikiriWeb.InitAssigns do
  import Phoenix.LiveView

  def on_mount(:user, params, session, socket) do
        auth_token = get_connect_params(socket)["auth_token"]
    case Pikiri.Guardian.decode_and_verify(auth_token, %{"typ" => "access"}) do
    {:ok, claims} -> 
        IO.puts("ok")
        {:cont, socket}
    {:error, error} ->
        IO.puts(error) 
        {:cont, socket}
    end
  end

  def on_mount(:admin, params, session, socket) do
    # code
  end
end