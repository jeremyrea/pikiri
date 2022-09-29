defmodule Pikiri.Repo.Migrations.CreatePostLikes do
  use Ecto.Migration

  def change do
    create table(:post_likes) do
      add :user_id, references(:users), null: false
      add :post_id, references(:posts), null: false

      timestamps()
    end

    create unique_index(:post_likes, [:user_id, :post_id], name: :ux_post_likes_user_id_post_id)
  end
end
