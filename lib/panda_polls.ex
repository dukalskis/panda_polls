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

  def subscribe(module, action, params \\ []) do
    topic = pubsub_topic(module, action, params)

    subscribe(topic)
  end

  def broadcast(topic, message) when is_binary(topic) do
    Phoenix.PubSub.broadcast(PandaPolls.PubSub, topic, message)
  end

  def broadcast(insert_or_update_result, module, action, params \\ [])

  def broadcast({:ok, struct}, module, action, params) do
    message = {module, {action, struct}}
    topic = pubsub_topic(module, action, params)

    broadcast(topic, message)

    {:ok, struct}
  end

  def broadcast({:error, changeset}, _module, _action, _params) do
    {:error, changeset}
  end

  def pubsub_topic(module, action, params) do
    topic = to_string(module) <> ":" <> to_string(action)

    Enum.reduce(params, topic, fn {key, value}, acc ->
      acc <> ":" <> to_string(key) <> "=" <> to_string(value)
    end)
  end
end
