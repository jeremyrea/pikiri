defmodule Pikiri.Users.User do
  use Ecto.Schema

  schema "users" do
    field :uuid, Ecto.UUID, autogenerate: true
    field :email, :string

    timestamps()
  end
end