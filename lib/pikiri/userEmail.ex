defmodule Pikiri.UserEmail do
  use Phoenix.Swoosh, view: PikiriWeb.EmailView

  def magic_link_email(user, magic_token, _extra_params) do
    new()
    |> to({nil, user.email})
    |> from({"Pikiri", System.get_env("EMAIL_FROM")})
    |> subject("Welcome to pikiri!")
    |> render_body("magic_link.html", %{magic_token: magic_token})
  end
end
