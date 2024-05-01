defmodule PandaPollsWeb.PollLive.Show do
  use PandaPollsWeb, :live_view

  alias PandaPolls.Polls
  alias PandaPolls.PollServer
  alias PandaPolls.Users

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    poll = Polls.get_poll!(id)

    poll_id = poll.id
    user_id = socket.assigns.current_user.id
    is_poll_owner = poll.user_id == user_id
    total_answers = length(poll.answers)

    vote = Polls.get_vote(poll_id, user_id)
    has_voted = !!vote
    vote_answer_id = vote && vote.answer_id

    author =
      if is_poll_owner,
        do: socket.assigns.current_user,
        else: Users.get_user(poll.user_id)

    if connected?(socket) do
      :ok = PandaPolls.subscribe(PandaPolls.Model.Poll, :updated, id: poll_id)
    end

    {:ok,
     socket
     |> assign_poll(poll)
     |> assign(:page_title, poll.question)
     |> assign(:user_id, user_id)
     |> assign(:total_answers, total_answers)
     |> assign(:has_voted, has_voted)
     |> assign(:author_username, author.username)
     |> assign(:vote_answer_id, vote_answer_id)}
  end

  @impl true
  def handle_event("select_answer", params, %{assigns: %{has_voted: false}} = socket) do
    %{"id" => answer_id} = params

    poll_id = socket.assigns.poll.id
    user_id = socket.assigns.user_id

    poll = PollServer.add_vote(poll_id, answer_id, user_id)
    vote = Polls.get_vote(poll.last_vote_id)

    {:noreply,
     socket
     |> assign_poll(poll)
     |> assign(:has_voted, true)
     |> assign(:vote_answer_id, vote.answer_id)}
  end

  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({PandaPolls.Model.Poll, {:updated, poll}}, socket) do
    old_poll = socket.assigns.poll

    socket =
      if poll.last_vote_id != old_poll.last_vote_id,
        do: assign_poll(socket, poll),
        else: socket

    {:noreply, socket}
  end

  def assign_poll(socket, poll) do
    total_votes = count_votes(poll.answers)

    socket
    |> assign(:poll, poll)
    |> assign(:total_votes, total_votes)
  end

  defp count_votes(answers) do
    Enum.reduce(answers, 0, fn answer, acc ->
      acc + answer.votes
    end)
  end

  defp answer_value(_answer_votes, _total_votes = 0), do: 0
  defp answer_value(_answer_votes = 0, _total_votes), do: 0

  defp answer_value(answer_votes, total_votes) do
    round(answer_votes / total_votes * 100)
  end
end
