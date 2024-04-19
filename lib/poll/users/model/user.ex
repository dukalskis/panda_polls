defmodule Poll.Model.User do
  use Poll.Model

  import Ecto.Query, only: [where: 3]

  schema "users" do
    field :username, :string
    # Username in lowercase. Use to check if username is unique.
    # Example: "UserName" == "username"
    field :username_lowercase, :string

    timestamps()
  end

  def changeset(%User{} = model, attrs \\ %{}) do
    fields = User.__schema__(:fields)

    model
    |> cast(attrs, fields)
    |> validate_required([:username])
  end

  def register_changeset(changeset) do
    username = get_change(changeset, :username)
    username_lowercase = String.downcase(username)

    changeset
    |> put_change(:username_lowercase, username_lowercase)
    |> validate_username_unique()
  end

  # Ecto.Changeset.unsafe_validate_unique/3 :query option is not working with etso.
  # Custom function to validate if username is unique.
  defp validate_username_unique(changeset) do
    username_lowercase = get_change(changeset, :username_lowercase)

    User
    |> where([u], u.username_lowercase == ^username_lowercase)
    |> Repo.one()
    |> then(fn
      nil -> changeset
      _user -> add_error(changeset, :username, "has already been taken")
    end)
  end
end
