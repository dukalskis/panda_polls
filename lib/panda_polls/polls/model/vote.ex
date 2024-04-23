defmodule PandaPolls.Model.Vote do
  use PandaPolls.Model

  schema "votes" do
    field :answer_id, UUIDv7
    belongs_to :poll, Model.Poll
    belongs_to :user, Model.User

    timestamps(updated_at: false)
  end

  def changeset(poll_id, answer_id, user_id) do
    change(%Vote{}, %{
      poll_id: poll_id,
      answer_id: answer_id,
      user_id: user_id
    })
  end
end
