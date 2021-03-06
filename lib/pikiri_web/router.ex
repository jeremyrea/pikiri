defmodule PikiriWeb.Router do
  use PikiriWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :public do
    plug :put_root_layout, {PikiriWeb.LayoutView, :public}
  end

  pipeline :authenticated do
    plug PikiriWeb.Plugs.EnsureRole, [:viewer, :contributor, :admin]
    plug :put_root_layout, {PikiriWeb.LayoutView, :root}
  end

  pipeline :admin do
    plug PikiriWeb.Plugs.EnsureRole, :admin
    plug :put_root_layout, {PikiriWeb.LayoutView, :root}
  end

  scope "/", PikiriWeb do
    pipe_through [:browser, :public]
    
    get "/login", LoginController, :new
    post "/login", LoginController, :create
    get "/auth", AuthController, :index
  end

  scope "/", PikiriWeb do
    pipe_through [:browser, :authenticated]

    live "/", Live.Feed
  end

  scope "/admin", PikiriWeb do
    pipe_through [:browser, :admin]

    live "/", Live.Admin
  end

  # Other scopes may use custom stacks.
  # scope "/api", PikiriWeb do
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

      live_dashboard "/dashboard", metrics: PikiriWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
