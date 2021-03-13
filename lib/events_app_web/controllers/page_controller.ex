defmodule EventsAppWeb.PageController do
  use EventsAppWeb, :controller

  def index(conn, _params) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: Routes.event_path(conn, :index))
    else
      conn
      |> redirect(to: Routes.user_path(conn, :new))
    end
  end
end
