defmodule PandaPolls.PollServer do
  @moduledoc """
  The Poll Server ensures that user can add only one vote for each poll.
  Each poll has its own PollServer.

  """

  use GenServer
  require Logger

  alias PandaPolls.Polls

  ## Client

  def start_link(init_arg) do
    poll_id = Keyword.fetch!(init_arg, :poll_id)

    GenServer.start_link(__MODULE__, poll_id, name: via(poll_id))
  end

  @doc """
  Add vote for the given poll and returns updated poll.

  ## Examples

      iex> add_vote(poll_id, answer_id, user_id)
      %PandaPolls.Model.Poll{}

  """
  def add_vote(poll_id, answer_id, user_id) do
    GenServer.call(via(poll_id), {:add_vote, answer_id, user_id})
  end

  ## Server (callbacks)

  @impl true
  def init(poll_id) do
    Logger.info("Starting PollServer #{inspect(poll_id)}")

    state = %{poll_id: poll_id}

    {:ok, state}
  end

  @impl true
  def handle_call({:add_vote, answer_id, user_id}, _from, state) do
    %{poll_id: poll_id} = state

    poll = Polls.get_poll(poll_id)
    vote = Polls.get_vote(poll_id, user_id)

    reply =
      if is_nil(vote) do
        # Not voted yet, add vote
        Polls.create_vote(poll, answer_id, user_id)
      else
        # Already voted
        poll
      end

    {:reply, reply, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.error("Terminate PollServer Reason: #{inspect(reason)}")
  end

  ## Private

  defp via(poll_id) do
    {:via, Registry, {PandaPolls.PollRegistry, poll_id}}
  end
end
