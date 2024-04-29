defmodule PandaPolls.Model.Poll do
  use PandaPolls.Model

  @min_answers 2

  schema "polls" do
    field :question, :string
    field :last_vote_id, UUIDv7

    belongs_to :user, Model.User
    embeds_many :answers, Model.Answer, on_replace: :delete

    timestamps()
  end

  def changeset(%Poll{} = model, attrs \\ %{}) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)

    model
    |> cast(attrs, fields -- embeds)
    |> validate_required([:question, :user_id])
    |> validate_length(:question, max: 240)
    |> cast_embed(:answers,
      required: true,
      required_message: "should have at least #{@min_answers} answers",
      sort_param: :answers_sort,
      drop_param: :answers_drop
    )
    |> validate_length(:answers,
      min: @min_answers,
      message: "should have at least %{count} answers"
    )
  end

  def update_answers_changeset(%Poll{} = model, answers, last_vote_id) do
    model
    |> change(last_vote_id: last_vote_id)
    |> put_embed(:answers, answers)
  end
end
