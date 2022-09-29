defmodule Pikiri.Posts.PostLikes do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pikiri.Users.User
  alias Pikiri.Posts.Post

  schema "post_likes" do
    belongs_to :user, User
    belongs_to :post, Post

    timestamps()
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:user_id, :post_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:post)
    |> unique_constraint(:ux_post_likes_user_id_post_id)
  end
end
