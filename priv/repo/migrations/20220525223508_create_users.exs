defmodule Pikiri.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :uuid, :uuid, null: false
      add :email, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:uuid])
  end
end
