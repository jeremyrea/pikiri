defmodule Pikiri.Users.User do
  use Ecto.Schema

  schema "users" do
    field :uuid, Ecto.UUID, autogenerate: true
    field :email, :string
    field :role, :string, default: "viewer"

    timestamps()
  end

  def changeset(user_or_changeset, _attrs) do
    user_or_changeset
  end

  @spec changeset_role(Ecto.Schema.t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset_role(user_or_changeset, attrs) do
    user_or_changeset
    |> Ecto.Changeset.cast(attrs, [:role])
    |> Ecto.Changeset.validate_inclusion(:role, ~w(viewer contributor admin))
  end
end