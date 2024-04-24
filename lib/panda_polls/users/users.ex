defmodule PandaPolls.Users do
  import Ecto.Query, warn: false

  alias PandaPolls.Model.User
  alias PandaPolls.Model.UserToken
  alias PandaPolls.Repo

  @doc """
  Gets the user with the given username.

  ## Examples

      iex> get_user_by_username(username)
      %User{}

      iex> get_user_by_username(wrong_username)
      nil

  """
  def get_user_by_username(username) do
    User
    |> where([u], u.username == ^username)
    |> Repo.one()
  end

  @doc """
  Gets the user with the given signed token.

  ## Examples

      iex> get_user_by_session_token(token)
      %User{}

      iex> get_user_by_session_token(wrong_token)
      nil

  """
  def get_user_by_session_token(token) do
    user_token =
      UserToken
      |> where([ut], ut.token == ^token)
      |> Repo.one()
      |> Repo.preload(:user)

    user_token && user_token.user
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user()
      %Ecto.Changeset{data: %User{}}

  """

  def change_user(attrs \\ %{})

  def change_user(%User{} = model) do
    User.changeset(model)
  end

  def change_user(attrs) do
    User.changeset(%User{}, attrs)
  end

  def change_user(%User{} = model, attrs) do
    User.changeset(model, attrs)
  end

  @doc """
  Generates a session token.

  ## Examples

      iex> generate_user_session_token(user)
      <<17, 136, 126, 40, 187, ...>>
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Deletes the signed token with the given context.

  ## Examples

      iex> delete_user_session_token(token)
      :ok
  """
  def delete_user_session_token(token) do
    UserToken
    |> where([ut], ut.token == ^token)
    |> Repo.delete_all()

    :ok
  end
end
