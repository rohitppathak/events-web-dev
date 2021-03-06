defmodule EventsAppWeb.SessionController do
  use EventsAppWeb, :controller

  def create(conn, %{"email" => email}) do
    user = EventsApp.Users.get_user_by_email(email)
    if user do
      conn
      |> put_session(:user_id, user.id)
      |> put_flash(:info, "Welcome back #{user.name}")
      |> redirect(to: Routes.page_path(conn, :index))
    else
      conn
      |> put_flash(:error, "User not found. Please register.")
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def create(conn, :user, user) do
    conn
    |> put_session(:user_id, user.id)
    |> put_flash(:info, "Welcome #{user.name}")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Logged out.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
