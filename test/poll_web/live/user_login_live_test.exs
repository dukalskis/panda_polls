defmodule PandaPollsWeb.UserLoginLiveTest do
  use PandaPollsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import PandaPolls.UsersFixtures

  describe "Log in page" do
    test "renders log in page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/log_in")

      assert html =~ "Log in to account"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/log_in")
        |> follow_redirect(conn, "/polls")

      assert {:ok, _conn} = result
    end
  end

  describe "user login" do
    test "redirects if user login with valid credentials", %{conn: conn} do
      user = user_fixture()

      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      form =
        form(lv, "#login_form", user: %{username: user.username})

      conn = submit_form(form, conn)

      assert redirected_to(conn) == ~p"/polls"
    end
  end

  describe "login navigation" do
    test "redirects to registration page when the Register button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|main a:fl-contains("Sign up")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/users/register")

      assert login_html =~ "Create Account"
    end
  end
end
