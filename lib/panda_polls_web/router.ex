defmodule PandaPollsWeb.Router do
  use PandaPollsWeb, :router

  import PandaPollsWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PandaPollsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PandaPollsWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/", PandaPollsWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{PandaPollsWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", PandaPollsWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", PandaPollsWeb do
  #   pipe_through :api
  # end
end
