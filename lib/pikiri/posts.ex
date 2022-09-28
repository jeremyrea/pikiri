defmodule Pikiri.Posts do
  alias Pikiri.{Repo, Posts.Post}
  import Ecto.Query

  @type t :: %Post{}

  @spec create_post(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def create_post(params) do
    %Post{}
    |> Post.changeset(params)
    |> Repo.insert()
  end

  @spec get_posts(Ecto.timestamps, integer) :: [Post]
  def get_posts(from, take) do
    Post
    |> where([p], p.inserted_at < ^from)
    |> limit(^take)
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end
end
