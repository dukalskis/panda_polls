defmodule PandaPolls.UsersTest do
  use PandaPolls.DataCase

  import PandaPolls.UsersFixtures

  alias PandaPolls.Model.User
  alias PandaPolls.Model.UserToken
  alias PandaPolls.Users
  alias PandaPolls.RegisterServer

  @nonexisting_id "018f0b97-0ab9-75b4-bd00-000c7584a6d1"

  describe "get_user/1" do
    test "does not return the user if the given id does not exist" do
      refute Users.get_user(@nonexisting_id)
    end

    test "returns the user with the given id" do
      %{id: id} = user_fixture()
      assert %User{id: ^id} = Users.get_user(id)
    end
  end

  describe "get_user_by_username/1" do
    test "does not return the user if the username does not exist" do
      refute Users.get_user_by_username("unknown_username")
    end

    test "returns the user if the username exists" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Users.get_user_by_username(user.username)
    end
  end

  describe "register_user/1" do
    test "requires username to be set" do
      {:error, changeset} = RegisterServer.register_user(%{})

      assert %{username: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates username uniqueness" do
      %{username: username} = user_fixture()
      {:error, changeset} = RegisterServer.register_user(%{username: username})
      assert "has already been taken" in errors_on(changeset).username

      userx = RegisterServer.register_user(%{username: String.upcase(username)})

      # Now try with the upper cased username too, to check that username case is ignored.
      {:error, changeset} = userx
      assert "has already been taken" in errors_on(changeset).username
    end
  end

  describe "change_user/2" do
    test "returns a user changeset" do
      user = user_fixture()

      assert %Ecto.Changeset{} = changeset = Users.change_user()
      assert changeset.required == [:username]

      assert %Ecto.Changeset{} = changeset = Users.change_user(%User{})
      assert changeset.required == [:username]

      assert %Ecto.Changeset{} = changeset = Users.change_user(user)
      assert user.username == get_field(changeset, :username)

      assert %Ecto.Changeset{} = changeset = Users.change_user(user, %{username: "usern"})
      assert "usern" == get_change(changeset, :username)
    end
  end

  describe "generate_user_session_token/1" do
    test "generates a token" do
      user = user_fixture()
      token = Users.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.user_id == user.id
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = Users.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Users.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Users.get_user_by_session_token("oops")
    end
  end

  describe "delete_user_session_token/1" do
    test "deletes the token" do
      user = user_fixture()
      token = Users.generate_user_session_token(user)
      assert Users.delete_user_session_token(token) == :ok
      refute Users.get_user_by_session_token(token)
    end
  end
end
