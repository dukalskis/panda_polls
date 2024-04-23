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
        answers: [
          %{answer: "Random answer 1"},
          %{answer: "Random answer 2"}
        ]
      })
      |> PandaPolls.Polls.create_poll()

    poll
  end
end
