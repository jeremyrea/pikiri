defmodule Pikiri.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs) do
      add :user_id, references(:users), null: false
      add :event, :string, null: false

      timestamps()
    end
  end
end
