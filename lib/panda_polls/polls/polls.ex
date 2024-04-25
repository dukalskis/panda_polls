defmodule PandaPolls.Polls do
  import Ecto.Query, warn: false

  alias PandaPolls.Model.Answer
  alias PandaPolls.Model.Poll
  alias PandaPolls.Model.Vote
  alias PandaPolls.Repo
  alias PandaPolls.PollServerSupervisor

  @doc """
  Returns the list of polls.

  ## Examples

      iex> list_polls()
      [%Poll{}, ...]

  """
  def list_polls do
    Poll
    |> order_by([p], desc: p.id)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Gets a poll by id.

  ## Examples

      iex> get_poll(id)
      %Poll{}

      iex> get_poll(wrong_id)
      nil

  """
  def get_poll(id), do: Repo.get(Poll, id)

  @doc """
  Gets a poll by id.

  Raises `Ecto.NoResultsError` if the Poll does not exist.

  ## Examples

      iex> get_poll!(id)
      %Poll{}

      iex> get_poll!(wrong_id)
      ** (Ecto.NoResultsError)

  """
  def get_poll!(id), do: Repo.get!(Poll, id)

  @doc """
  Gets a vote by poll_id and user_id.

  ## Examples

      iex> get_vote(poll_id, user_id)
      %Vote{}

      iex> get_vote(poll_id, wrong_user_id)
      nil

  """
  def get_vote(poll_id, user_id) do
    Vote
    |> where([p], p.poll_id == ^poll_id)
    |> where([p], p.user_id == ^user_id)
    |> Repo.one()
  end

  @doc """
  Creates a poll.

  ## Examples

      iex> create_poll(params)
      {:ok, %Poll{}}

      iex> create_poll(params_not_valid)
      {:error, %Ecto.Changeset{}}

  """
  def create_poll(params) do
    params
    |> change_poll()
    |> Repo.insert()
    # Start GenServer for each poll
    |> start_server()
  end

  defp start_server({:ok, %Poll{} = poll}) do
    PollServerSupervisor.start_child(poll_id: poll.id)
    {:ok, poll}
  end

  defp start_server({:error, changeset}) do
    {:error, changeset}
  end

  @doc """
  Creates a vote.

  Add votes data (poll_id, answer_id, user_id) to the votes table.
  Inc votes number for the given poll.

  ## Examples

      iex> create_vote(poll, answer_id, user_id)
      %Poll{}

  """
  def create_vote(poll, answer_id, user_id) do
    {:ok, _vote} =
      poll.id
      |> Vote.changeset(answer_id, user_id)
      |> Repo.insert()

    {:ok, poll} = inc_answer_votes(poll, answer_id)

    poll
  end

  defp inc_answer_votes(poll, answer_id) do
    answers =
      Enum.map(poll.answers, fn
        %Answer{id: ^answer_id} = answer ->
          Answer.changeset(answer, %{votes: answer.votes + 1})

        answer ->
          Answer.changeset(answer)
      end)

    poll
    |> Poll.update_answers_changeset(answers)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking poll changes.

  ## Examples

      iex> change_poll()
      %Ecto.Changeset{data: %Poll{}}

  """

  def change_poll(attrs \\ %{})

  def change_poll(%Poll{} = model) do
    Poll.changeset(model)
  end

  def change_poll(attrs) do
    Poll.changeset(%Poll{}, attrs)
  end

  def change_poll(%Poll{} = model, attrs) do
    Poll.changeset(model, attrs)
  end
end
