defmodule PandaPollsWeb.UserSessionController do
  use PandaPollsWeb, :controller

  alias PandaPolls.Users
  alias PandaPollsWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"username" => username} = user_params

    if user = Users.get_user_by_username(username) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user)
    else
      conn
      |> put_flash(:error, "Invalid username")
      |> put_flash(:username, username)
      |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
