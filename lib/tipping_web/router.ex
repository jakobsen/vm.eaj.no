defmodule TippingWeb.Router do
  use TippingWeb, :router

  import TippingWeb.Auth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TippingWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TippingWeb do
    pipe_through [:browser, :redirect_authenticated_user]

    get "/", PageController, :home
    get "/logg-inn/google", AuthController, :google_login
    get "/logg-inn/microsoft", AuthController, :microsoft_login
  end

  scope "/auth", TippingWeb do
    pipe_through :browser

    get "/google/callback", AuthController, :google_callback
    get "/microsoft/callback", AuthController, :microsoft_callback
  end

  scope "/", TippingWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/regler", PageController, :rules

    post "/logg-ut", AuthController, :log_out

    live_session :require_authenticated, on_mount: [{TippingWeb.Auth, :require_authenticated}] do
      live "/kamper", MatchListLive
      live "/tabell", PointsTableLive
    end
  end

  scope "/admin", TippingWeb do
    pipe_through [:browser, :require_admin_user]

    live_session :require_admin, on_mount: [{TippingWeb.Auth, :require_admin}] do
      live "/", Admin.MatchesLive
      live "/kamper/:id", Admin.MatchFormLive
      live "/eventyr", Admin.MatchStoriesLive
    end
  end

  scope "/api", TippingWeb do
    pipe_through :api

    get "/health", HealthController, :health
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:tipping, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TippingWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
