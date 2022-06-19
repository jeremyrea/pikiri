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
end