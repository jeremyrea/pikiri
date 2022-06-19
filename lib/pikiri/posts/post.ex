defmodule Pikiri.Posts.Post do
  use Ecto.Schema

  alias Pikiri.Users.User

  schema "posts" do
    belongs_to :user, User

    timestamps()
  end

  def changeset(post_or_changeset, attrs \\ %{}) do
    post_or_changeset
    |> Ecto.Changeset.cast(attrs, [:user_id])
  end
end