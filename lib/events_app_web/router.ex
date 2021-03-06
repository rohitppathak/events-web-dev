defmodule EventsAppWeb.Router do
  use EventsAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug EventsAppWeb.Plugs.FetchSession
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EventsAppWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/events", EventController
    resources "/invites", InviteController
    post "/invites/:id", InviteController, :update
    get "/users/photo/:id", UserController, :photo
    get "/users", UserController, :index
    get "/users/:id/edit", UserController, :edit
    get "/users/new", UserController, :new
    get "/users/:id", UserController, :show
    post "/users", UserController, :create_or_update
    patch "/users/:id", UserController, :update
    put "/users/:id", UserController, :update
    delete "/users/:id", UserController, :delete
    resources "/sessions", SessionController,
     only: [:create, :delete], singleton: true
  end

  # Other scopes may use custom stacks.
  # scope "/api", EventsAppWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: EventsAppWeb.Telemetry
    end
  end
end
