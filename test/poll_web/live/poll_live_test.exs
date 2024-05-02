defmodule PandaPollsWeb.PollLiveTest do
  use PandaPollsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import PandaPolls.UsersFixtures
  import PandaPolls.PollsFixtures

  test "list polls", %{conn: conn} do
    user = user_fixture()

    poll = poll_fixture(%{question: "questionX", user_id: user.id})

    {:ok, lv, _html} =
      conn
      |> log_in_user(user)
      |> live(~p"/polls")

    # Has title
    assert lv
           |> element("main h1")
           |> render() =~ "Polls"

    # Has element in the table
    poll_row = element(lv, "#polls-" <> poll.id) |> render()

    assert poll_row =~ poll.question
    assert poll_row =~ user.username
    assert poll_row =~ to_string(poll.inserted_at)
  end

  test "add a poll", %{conn: conn} do
    {:ok, lv, _html} =
      conn
      |> log_in_user(user_fixture())
      |> live(~p"/polls")

    # Open form
    lv
    |> element(~s|[href="/polls/new"]|)
    |> render_click()

    path = assert_patch(lv)
    assert path == "/polls/new"

    # Fill the form and submit
    form =
      form(lv, "#poll-form",
        poll: %{
          question: "FormQuestion",
          answers: %{
            "0" => %{answer: "Random answer 1"},
            "1" => %{answer: "Random answer 2"}
          }
        }
      )

    render_submit(form)

    path = assert_patch(lv)
    assert path == "/polls"

    assert render(lv) =~ "Poll created successfully"
  end

  test "add a vote", %{conn: conn} do
    user = user_fixture()

    poll =
      poll_fixture(%{
        question: "Random question",
        user_id: user.id,
        answers: [
          %{answer: "Answer1"},
          %{answer: "Answer2"}
        ]
      })

    conn = log_in_user(conn, user)

    {:ok, lv, _html} = live(conn, ~p"/polls")

    # Opens poll page
    {:ok, poll_lv, _html} =
      element(lv, "#polls-#{poll.id} > :first-child")
      |> render_click()
      |> follow_redirect(conn)

    {path, _flash} = assert_redirect(lv)
    assert path == "/polls/#{poll.id}"

    # Add vote
    poll_lv
    |> element(~s|main button:fl-contains("Answer1")|)
    |> render_click()

    assert render(poll_lv) =~ "1 vote"

    answer = hd(poll.answers)
    answer_results = element(poll_lv, "#answer_" <> answer.id) |> render()

    assert answer_results =~ "100%"
    assert answer_results =~ "hero-check-badge-solid"
  end
end
