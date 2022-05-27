defmodule Pikiri.Repo.Migrations.AddUserStatus do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :status, :string, null: false, default: "pending"
    end
  end
end
