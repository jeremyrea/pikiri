defmodule Pikiri.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :user_id, references(:users), null: false

      timestamps()
    end
  end
end
