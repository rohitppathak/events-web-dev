defmodule EventsAppWeb.Plugs.RequireUser do
  use EventsAppWeb, :controller

  def init(args), do: args

  def call(conn, _args) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to do that.")
      |> redirect(to: Routes.user_path(conn, :new))
      |> halt()
    end
  end
end
