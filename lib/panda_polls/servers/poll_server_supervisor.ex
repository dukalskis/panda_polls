defmodule PandaPolls.PollServerSupervisor do
  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(arg) do
    DynamicSupervisor.start_child(
      __MODULE__,
      %{
        id: PandaPolls.PollServer,
        start: {PandaPolls.PollServer, :start_link, [arg]},
        restart: :permanent
      }
    )
  end
end
