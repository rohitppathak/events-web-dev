defmodule EventsApp.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :body, :string
    field :title, :string
    field :date, :date
    belongs_to :user, EventsApp.Users.User
    has_many :invites, EventsApp.Invites.Invite

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :body, :date, :user_id])
    |> validate_required([:title, :body, :date, :user_id])
  end
end
