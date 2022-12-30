defmodule Pikiri.Repo do
  use Ecto.Repo,
    otp_app: :pikiri,
    adapter: Ecto.Adapters.Postgres
end
