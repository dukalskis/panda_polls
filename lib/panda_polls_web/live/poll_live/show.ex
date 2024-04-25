defmodule PandaPollsWeb.PollLive.Show do
  use PandaPollsWeb, :live_view

  alias PandaPolls.Polls

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    poll = Polls.get_poll!(id)

    {:ok,
     socket
     |> assign(:page_title, poll.question)
     |> assign(:poll, poll)}
  end
end
