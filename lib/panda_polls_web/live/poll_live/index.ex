defmodule PandaPollsWeb.PollLive.Index do
  use PandaPollsWeb, :live_view

  alias PandaPolls.Polls
  alias PandaPolls.Users

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :ok = PandaPolls.subscribe(PandaPolls.Model.Poll, :created)
    end

    {:ok,
     socket
     |> assign(:user_id, socket.assigns.current_user.id)
     |> stream(:polls, Polls.list_polls())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, page_title(socket.assigns.live_action))}
  end

  defp page_title(:new), do: "New Poll"
  defp page_title(:index), do: "Polls"

  @impl true
  def handle_info({PandaPolls.Model.Poll, {:created, poll}}, socket) do
    user = Users.get_user(poll.user_id)
    poll = Map.put(poll, :user, user)

    {:noreply, stream_insert(socket, :polls, poll, at: 0)}
  end
end
