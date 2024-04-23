defmodule PandaPolls.PollsTest do
  use PandaPolls.DataCase

  import PandaPolls.PollsFixtures

  alias PandaPolls.Model.Answer
  alias PandaPolls.Model.Poll
  alias PandaPolls.Model.Vote
  alias PandaPolls.Polls



  describe "polls" do
    test "list_polls/0 returns all polls" do
      poll = poll_fixture()
      assert Polls.list_polls() == [poll]
    end
  end
end
