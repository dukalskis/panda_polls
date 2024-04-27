defmodule PandaPolls do
  @moduledoc """
  PandaPolls keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def subscribe(topic) when is_binary(topic) do
    Phoenix.PubSub.subscribe(PandaPolls.PubSub, topic)
  end

  def subscribe(module, action) do
    {module, action}
    |> pubsub_topic()
    |> subscribe()
  end

  def broadcast(topic, message) when is_binary(topic) do
    Phoenix.PubSub.broadcast(PandaPolls.PubSub, topic, message)
  end

  def broadcast({:ok, struct}, module, action) do
    broadcast(module, action, struct)
    {:ok, struct}
  end

  def broadcast({:error, changeset}, _module, _action) do
    {:error, changeset}
  end

  def broadcast(module, action, payload) do
    message = {module, {action, payload}}

    {module, action}
    |> pubsub_topic()
    |> broadcast(message)
  end

  defp pubsub_topic({module, action}) do
    to_string(module) <> ":" <> to_string(action)
  end
end
