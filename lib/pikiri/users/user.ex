defmodule Pikiri.Users.User do
  use Ecto.Schema

  alias Pikiri.Posts.Post

  schema "users" do
    field :uuid, Ecto.UUID, autogenerate: true
    field :email, :string
    field :role, :string, default: "viewer"
    field :status, :string, default: "pending"

    has_many :posts, Post

    timestamps()
  end

  def changeset(user_or_changeset, attrs \\ %{}) do
    user_or_changeset
    |> Ecto.Changeset.cast(attrs, [:email, :role, :status])
  end

  @spec changeset_email(Ecto.Schema.t() | Ecto.Changeset.t(), %{email: String.t()}) :: Ecto.Changeset.t()
  def changeset_email(user_or_changeset, attrs) do
    user_or_changeset
    |> Ecto.Changeset.cast(attrs, [:email])
  end

  @spec changeset_role(Ecto.Schema.t() | Ecto.Changeset.t(), %{role: String.t()}) :: Ecto.Changeset.t()
  def changeset_role(user_or_changeset, attrs) do
    user_or_changeset
    |> Ecto.Changeset.cast(attrs, [:role])
    |> Ecto.Changeset.validate_inclusion(:role, ~w(viewer contributor admin))
  end

  @spec changeset_role(Ecto.Schema.t() | Ecto.Changeset.t(), %{status: String.t()}) :: Ecto.Changeset.t()
  def changeset_status(user_or_changeset, attrs) do
    user_or_changeset
    |> Ecto.Changeset.cast(attrs, [:status])
    |> Ecto.Changeset.validate_inclusion(:status, ~w(pending confirmed disabled))
  end
end
