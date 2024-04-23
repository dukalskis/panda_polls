defmodule PandaPolls.PollsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PandaPolls.Polls` context.
  """

  @doc """
  Generate a poll.
  """
  def poll_fixture(attrs \\ %{}) do
    {:ok, poll} =
      attrs
      |> Enum.into(%{
        question: "Random question",
        user_id: "018f0b97-0ab9-75b4-bc00-001b8af94f9d",
        answers: [
          %{answer: "Random answer 1"},
          %{answer: "Random answer 2"}
        ]
      })
      |> PandaPolls.Polls.create_poll()

    poll
  end
end
