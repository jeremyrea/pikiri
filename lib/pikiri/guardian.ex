defmodule Pikiri.Guardian do
  use Guardian, otp_app: :pikiri
  use SansPassword

  def subject_for_token(%{uuid: uuid}, _claims) do
    sub = to_string(uuid)
    {:ok, sub}
  end
  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => uuid}) do
    resource = Pikiri.Users.get_user(uuid)
    {:ok, resource}
  end
  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end

  @impl true
  def deliver_magic_link(user, magic_token, extra_params) do
    user
    |> Pikiri.UserEmail.magic_link_email(magic_token, extra_params)
    |> Pikiri.Mailer.deliver
  end
end