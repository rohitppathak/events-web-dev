defmodule EventsAppWeb.EventController do
  use EventsAppWeb, :controller

  alias EventsApp.Events
  alias EventsApp.Events.Event
  alias EventsApp.Invites
  alias EventsApp.Invites.Invite
  alias EventsAppWeb.Plugs.RequireUser

  plug RequireUser when action in [:index, :new, :create, :show, :edit, :update, :delete]
  plug :fetch_event when action in [:show, :edit, :update, :delete]
  plug :require_owner when action in [:edit, :update, :delete]

  def fetch_event(conn, _args) do
    id = conn.params["id"]
    event = Events.get_event!(id)
    assign(conn, :event, event)
  end

  def require_owner(conn, _args) do
    user = conn.assigns[:current_user]
    event = conn.assigns[:event]

    if user.id == event.user_id do
      conn
    else
      conn
      |> put_flash(:error, "That isn't yours.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def index(conn, _params) do
    events = Events.list_filtered_events(conn.assigns[:current_user].id)
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Events.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    event_params = event_params
    |> Map.put("user_id", conn.assigns[:current_user].id)
    case Events.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def count_invites(invites, acc \\ %{3 => 0, 2 => 0, 1 => 0, 0 => 0}) do
    case invites do
      [head | tail] -> count_invites(tail, Map.put(acc, head.status, Map.get(acc, head.status) + 1))
      [] -> acc
    end
  end

  def show(conn, %{"id" => id}) do
    event = conn.assigns[:event]
    |> Events.load_invites()
    invite_count = count_invites(event.invites)
    changeset = Invites.change_invite(%Invite{
      event_id: event.id,
      status: 0
    })
    invite = Invites.get_invite(event.id, conn.assigns[:current_user].id)
    render(conn, "show.html", event: event, changeset: changeset, invite: invite, invite_count: invite_count)
  end

  def edit(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    changeset = Events.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def event_page(conn, id) do
    event = Events.get_event!(id)
    redirect(conn, to: Routes.event_path(conn, :show, event))
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Events.get_event!(id)

    case Events.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    {:ok, _event} = Events.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end
