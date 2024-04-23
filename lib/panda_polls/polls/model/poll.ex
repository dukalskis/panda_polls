defmodule PandaPolls.Model.Poll do
  use PandaPolls.Model

  schema "polls" do
    field :question, :string

    embeds_many :answers, Model.Answer

    timestamps()
  end

  def changeset(%Poll{} = model, attrs \\ %{}) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)

    model
    |> cast(attrs, fields -- embeds)
    |> validate_required([:question])
    |> cast_embed(:answers, required: true)
  end

  def update_answers_changeset(%Poll{} = model, answers) do
    model
    |> change()
    |> put_embed(:answers, answers)
  end
end
