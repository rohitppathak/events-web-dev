defmodule EventsApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false, default: ""
      add :email, :string, null: false
      add :photo_hash, :text, null: false, default: ""

      timestamps()
    end

    create unique_index(:users, [:email], name: :email_unique)
  end
end
