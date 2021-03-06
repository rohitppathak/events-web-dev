defmodule EventsApp.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :title, :text, null: false
      add :body, :text, null: false
      add :date, :date, null: false

      timestamps()
    end

  end
end
