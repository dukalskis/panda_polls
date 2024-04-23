defmodule PandaPolls.PollSupervisor do
  use Supervisor

  alias PandaPolls.Polls
  alias PandaPolls.PollServerSupervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Registry, [keys: :unique, name: PandaPolls.PollRegistry]},
      {PollServerSupervisor, []},
      {Task, fn -> start_poll_servers() end}
    ]

    # :one_for_all - if a child process terminates, all other child processes are terminated
    # and then all child processes (including the terminated one) are restarted.
    Supervisor.init(children, strategy: :one_for_all)
  end

  defp start_poll_servers() do
    # If all child processes are terminated and now its restarting,
    # then starts poll servers for each poll

    Polls.list_polls()
    |> Enum.each(fn poll ->
      PollServerSupervisor.start_child(poll_id: poll.id)
    end)
  end
end
