defmodule Pikiri.Logs.Log do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pikiri.Users.User

  schema "logs" do
    field :event, :string

    belongs_to :user, User

    timestamps()
  end

  def changeset(log_or_changeset, attrs \\ %{}) do
    log_or_changeset
    |> cast(attrs, [:user_id, :event])
    |> assoc_constraint(:user)
    |> validate_inclusion(:event, ["login_email"])
  end
end
