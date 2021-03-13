defmodule EventsAppWeb.InviteController do
  use EventsAppWeb, :controller

  alias EventsApp.Invites
  alias EventsApp.Invites.Invite
  alias EventsAppWeb.UserController
  alias EventsAppWeb.EventController

  def index(conn, _params) do
    invites = Invites.list_invites()
    render(conn, "index.html", invites: invites)
  end

  def new(conn, _params) do
    changeset = Invites.change_invite(%Invite{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"invite" => invite_params}) do
    {email, invite_params} = Map.pop(invite_params, "email")
    user = UserController.create_or_get(conn, email)
    invite_params = invite_params
    |> Map.put("user_id", user.id)
    case Invites.create_invite(invite_params) do
      {:ok, invite} ->
        conn
        |> put_flash(:info, "Invite created successfully.")
        |> EventController.event_page(invite_params["event_id"])

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "This user is already invited.")
        |> EventController.event_page(invite_params["event_id"])
    end
  end

  def show(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    render(conn, "show.html", invite: invite)
  end

  def edit(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    changeset = Invites.change_invite(invite)
    render(conn, "edit.html", invite: invite, changeset: changeset)
  end

  def update(conn, %{"id" => id, "invite" => invite_params}) do
    map = %{
    "Yes" => 3,
    "Maybe" => 2,
    "No" => 1
    }
    invite = Invites.get_invite!(id)
    invite_params = if invite_params["comment"] == nil do
      Map.put(invite_params, "comment", "")
    else
      invite_params
    end
    status = Map.get(map, Map.get(invite_params, "status"))
    invite_params = Map.put(invite_params, "status", status)
    |> Map.put("user_id", conn.assigns[:current_user].id)
    case Invites.update_invite(invite, invite_params) do
      {:ok, invite} ->
        conn
        |> put_flash(:info, "Invite updated successfully.")
        |> EventController.event_page(invite_params["event_id"])

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", invite: invite, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    |> Invites.load_event
    event = invite.event
    user = conn.assigns[:current_user]
    if invite.user_id == user.id or event.user_id == user.id do
      case Invites.update_invite(invite, %{"comment" => ""}) do
        {:ok, invite} ->
          conn
          |> put_flash(:info, "Comment deleted.")
          |> EventController.event_page(event.id)

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", invite: invite, changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "This isn't you.")
      |> EventController.event_page(event.id)
    end
  end
end
