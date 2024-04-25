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

    delete "/users/log_out", UserSessionController, :delete
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
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{PandaPollsWeb.UserAuth, :ensure_authenticated}] do
      live "/polls", PollLive.Index, :index
      live "/polls/new", PollLive.Index, :new
      live "/polls/:id", PollLive.Show, :show
    end
  end
end
