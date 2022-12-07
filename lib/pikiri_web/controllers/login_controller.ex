defmodule PikiriWeb.LoginController do
  use PikiriWeb, :controller
  import Plug.Conn

  alias Pikiri.Users
  alias Pikiri.Guardian

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"email" => email}) do
    email
    |> Users.get_user_by_email()
    |> Guardian.send_magic_link()

    render(conn, "show.html", email: email)
  end
end
