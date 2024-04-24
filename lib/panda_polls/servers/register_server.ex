defmodule PandaPolls.RegisterServer do
  @moduledoc """
  The Register Server ensures that two identical usernames are not added simultaneously.
  """

  use GenServer

  alias PandaPolls.Model.User
  alias PandaPolls.Users
  alias PandaPolls.Repo

  ## Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(params)
      {:ok, %User{}}

      iex> register_user(params_not_valid)
      {:error, %Ecto.Changeset{}}

  """
  def register_user(params) do
    changeset = Users.change_user(params)

    if changeset.valid?,
      do: GenServer.call(__MODULE__, {:register_user, changeset}),
      else: {:error, changeset}
  end

  ## Server (callbacks)

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:register_user, changeset}, _from, state) do
    reply =
      changeset
      |> User.register_changeset()
      |> Repo.insert()

    {:reply, reply, state}
  end
end
