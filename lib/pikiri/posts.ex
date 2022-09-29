defmodule Pikiri.Posts do
  alias Pikiri.{Repo, Posts.Post, Posts.PostLikes}
  import Ecto.Query

  @type t :: %Post{}

  @spec create_post(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def create_post(params) do
    %Post{}
    |> Post.changeset(params)
    |> Repo.insert()
  end

  @spec get_posts(Ecto.timestamps, integer, integer) :: [Post]
  def get_posts(from, take, user_id) do
    Post
    |> where([p], p.inserted_at < ^from)
    |> limit(^take)
    |> join(:left, [p], pl in PostLikes, on: p.id == pl.post_id and pl.user_id == ^user_id)
    |> select([p, pl], %{p | liked: not is_nil(pl.post_id)})
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  @spec get_post(integer, integer) :: Post
  def get_post(post_id, user_id) do
    Post
    |> where([p], p.id == ^post_id)
    |> join(:left, [p], pl in PostLikes, on: p.id == pl.post_id and pl.user_id == ^user_id)
    |> select([p, pl], %{p | liked: not is_nil(pl.post_id)})
    |> Repo.one()
  end

  @spec like_post(integer, integer) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def like_post(user_id, post_id) do
    %PostLikes{}
    |> PostLikes.changeset(%{user_id:  user_id, post_id: post_id})
    |> Repo.insert()
  end

  @spec unlike_post(integer, integer) :: {non_neg_integer(), nil | [term()]}
  def unlike_post(user_id, post_id) do
    from(l in PostLikes, where: l.user_id == ^user_id and l.post_id == ^post_id)
    |> Repo.delete_all()
  end
end
