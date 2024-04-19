defmodule Poll.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poll.Users`.
  """

  def unique_username, do: "username#{System.unique_integer()}"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      username: unique_username()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Poll.Users.register_user()

    user
  end
end
