defmodule EventsApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email], name: :email_unique)
  end
end
