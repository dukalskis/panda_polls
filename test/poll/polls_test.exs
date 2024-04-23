defmodule PandaPolls.PollsTest do
  use PandaPolls.DataCase

  import PandaPolls.PollsFixtures

  alias PandaPolls.Model.Poll
  alias PandaPolls.Polls
  alias PandaPolls.PollServer

  @nonexisting_id "018f0b97-0ab9-75b4-bd00-000c7584a6d1"

  describe "Polls.list_polls/0" do
    test "returns all polls" do
      poll = poll_fixture()
      list_polls = Polls.list_polls()

      assert Enum.find(list_polls, fn p -> p.id == poll.id end)
    end
  end

  describe "Polls.get_poll/1" do
    test "does not return the poll if the given id does not exist" do
      refute Polls.get_poll(@nonexisting_id)
    end

    test "returns the poll with the given id" do
      %{id: id} = poll_fixture()
      assert %Poll{id: ^id} = Polls.get_poll(id)
    end
  end

  describe "Polls.get_poll!/1" do
    test "raises `Ecto.NoResultsError` if the Poll does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Polls.get_poll!(@nonexisting_id)
      end
    end

    test "returns the poll with the given id" do
      %{id: id} = poll_fixture()
      assert %Poll{id: ^id} = Polls.get_poll!(id)
    end
  end

  describe "Polls.create_poll/1" do
    test "requires question and answers to be set" do
      {:error, changeset} = Polls.create_poll(%{question: ""})

      assert %{question: ["can't be blank"], answers: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires answer to be set" do
      {:error, changeset} = Polls.create_poll(%{answers: [%{answer: ""}]})

      assert %{answers: [%{answer: ["can't be blank"]}]} = errors_on(changeset)
    end

    test "requires at least 2 answers" do
      {:error, changeset} = Polls.create_poll(%{answers: [%{answer: "a1"}]})

      assert %{answers: ["should have at least 2 item(s)"]} = errors_on(changeset)
    end

    test "validates max length of the question" do
      question = String.duplicate("a", 250)
      {:error, changeset} = Polls.create_poll(%{question: question})

      assert %{question: ["should be at most 240 character(s)"]} = errors_on(changeset)
    end

    test "validates max length of the answer" do
      answer = String.duplicate("a", 130)
      {:error, changeset} = Polls.create_poll(%{answers: [%{answer: answer}]})

      assert %{answers: [%{answer: ["should be at most 120 character(s)"]}]} =
               errors_on(changeset)
    end

    test "validates if the poll server is started" do
      %{id: id} = poll_fixture()

      assert [{_pid, _}] = Registry.lookup(PandaPolls.PollRegistry, id)
    end
  end

  describe "Polls.create_vote/3" do
    test "create vote for the poll" do
      poll = poll_fixture()
      answer = hd(poll.answers)
      poll_id = poll.id
      answer_id = answer.id
      user_id = "018f0b97-0ab9-75b4-bc00-001b8af94f9d"

      # Check if the vote table updated

      assert nil == Polls.get_vote(poll.id, user_id)

      updated_poll = Polls.create_vote(poll, answer.id, user_id)
      vote = Polls.get_vote(poll.id, user_id)

      assert %{poll_id: ^poll_id, answer_id: ^answer_id, user_id: ^user_id} = vote

      # Check if the votes count updated (+1)

      updated_answer = get_answer(updated_poll.answers, answer_id)

      assert updated_answer.votes == answer.votes + 1
    end
  end

  describe "Polls.change_poll/2" do
    test "returns a poll changeset" do
      poll = poll_fixture()

      assert %Ecto.Changeset{} = changeset = Polls.change_poll()
      assert Enum.member?(changeset.required, :question)

      assert %Ecto.Changeset{} = changeset = Polls.change_poll(%Poll{})
      assert Enum.member?(changeset.required, :question)

      assert %Ecto.Changeset{} = changeset = Polls.change_poll(poll)
      assert poll.question == get_field(changeset, :question)

      assert %Ecto.Changeset{} = changeset = Polls.change_poll(poll, %{question: "new question"})
      assert "new question" == get_change(changeset, :question)
    end
  end

  describe "PollServer.add_vote/3" do
    test "validates votes uniqueness" do
      poll = poll_fixture()
      answer = hd(poll.answers)
      user_id = "018f0b97-0ab9-75b4-bc00-001b8af94f9d"

      # Check if the votes count updated (+1)

      updated_1_poll = PollServer.add_vote(poll.id, answer.id, user_id)

      updated_1_answer = get_answer(updated_1_poll.answers, answer.id)

      assert updated_1_answer.votes == answer.votes + 1

      # Vote one more time, but not allowed, return unchanged poll

      updated_2_poll = PollServer.add_vote(poll.id, answer.id, user_id)

      updated_2_answer = get_answer(updated_2_poll.answers, answer.id)

      assert updated_2_answer.votes == updated_1_answer.votes
    end
  end

  defp get_answer(answers, answer_id) do
    Enum.find(answers, fn %{id: id} -> id == answer_id end)
  end
end
