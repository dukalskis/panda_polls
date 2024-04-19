defmodule PandaPolls.Model.UserToken do
  use PandaPolls.Model

  @rand_size 32

  schema "users_tokens" do
    field :token, :binary
    belongs_to :user, Model.User

    timestamps(updated_at: false)
  end

  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)

    {token, %UserToken{token: token, user_id: user.id}}
  end
end
