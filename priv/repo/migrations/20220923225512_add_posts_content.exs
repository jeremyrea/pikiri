defmodule Pikiri.Repo.Migrations.AddPostsContent do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :content, :map
    end
  end
end
