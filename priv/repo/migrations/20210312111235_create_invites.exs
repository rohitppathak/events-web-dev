defmodule EventsApp.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites) do
      add :status, :integer, null: false, default: 0
      add :comment, :text, default: ""
      add :user_id, references(:users, on_delete: :nothing)
      add :event_id, references(:events, on_delete: :nothing)

      timestamps()
    end

    create index(:invites, [:user_id])
    create index(:invites, [:event_id])
    create unique_index(:invites, [:user_id, :event_id], name: :invite_unique)
  end
end
