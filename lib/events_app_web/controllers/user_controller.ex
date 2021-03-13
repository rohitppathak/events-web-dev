defmodule EventsAppWeb.UserController do
  use EventsAppWeb, :controller

  alias EventsApp.Users
  alias EventsApp.Users.User
  alias EventsApp.Photos
  alias EventsAppWeb.Plugs.RequireUser

  plug RequireUser when action in [:index, :create, :show, :edit, :update, :delete]
  plug :fetch_user when action in [:show, :edit, :update, :delete]
  plug :require_owner when action in [:edit, :update, :delete]

  def fetch_user(conn, _args) do
    id = conn.params["id"]
    user = Users.get_user!(id)
    assign(conn, :user, user)
  end

  def require_owner(conn, _args) do
    user = conn.assigns[:current_user]
    u = conn.assigns[:user]

    if user.id == u.user_id do
      conn
    else
      conn
      |> put_flash(:error, "That's not you.")
      |> redirect(to: Routes.user_path(conn, :index))
      |> halt()
    end
  end

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Users.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}, invite \\ false) do
    upload = user_params["photo"]
    user_params = if upload do
      {:ok, hash} = Photos.save_photo(upload.filename, upload.path)
      user_params = user_params
      |> Map.put("photo_hash", hash)
    else
      user_params
    end
    case Users.create_user(user_params, invite) do
      {:ok, user} ->
        EventsAppWeb.SessionController.create(conn, :user, user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def create_or_update(conn, %{"user" => user_params}) do
    user = Users.get_unregistered_user(user_params["email"])
    if user do
      case Users.update_user(user, user_params) do
        {:ok, user} ->
          EventsAppWeb.SessionController.create(conn, :user, user)

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", user: user, changeset: changeset)
      end
    else
      create(conn, %{"user" => user_params})
    end
  end

  def create_or_get(conn, email) do
    user = Users.get_user_by_email(email)
    if user do
      user
    else
      case Users.create_user(%{"email": email, "name": ""}, true) do
        {:ok, new_user} ->
          new_user

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> put_flash(:error, "Could not invite user.")
      end
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    changeset = Users.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)
    upload = user_params["photo"]
    user_params = if upload do
      Photos.delete(user.photo_hash)
      {:ok, hash} = Photos.save_photo(upload.filename, upload.path)
      Map.put(user_params, "photo_hash", hash)
    else
      user_params
    end
    case Users.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def photo(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    {:ok, _name, data} = Photos.load_photo(user.photo_hash)
    conn
    |> put_resp_content_type("image/jpeg")
    |> send_resp(200, data)
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    {:ok, _user} = Users.delete_user(user)
    Photos.delete(user.photo_hash)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
