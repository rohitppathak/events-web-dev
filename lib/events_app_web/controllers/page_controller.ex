defmodule EventsAppWeb.PageController do
  use EventsAppWeb, :controller

  def index(conn, _params) do
    conn
    |> redirect(to: Routes.event_path(conn, :index))
  end
end
