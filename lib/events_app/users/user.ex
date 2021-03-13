defmodule EventsApp.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :photo_hash, :string
    has_many :events, EventsApp.Events.Event
    has_many :invites, EventsApp.Invites.Invite

    timestamps()
  end

  @doc false
  def changeset(user, attrs, invite \\ false) do
    required = if invite do
      [:email]
    else
      [:name, :email]
    end
    user
    |> cast(attrs, [:name, :email, :photo_hash])
    |> validate_required(required)
    |> unique_constraint(:email, name: :email_unique)
  end
end
