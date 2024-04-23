defmodule PandaPolls.Model.Answer do
  use PandaPolls.Model

  embedded_schema do
    field :answer, :string
    field :votes, :integer, default: 0
  end

  def changeset(%Answer{} = model, attrs \\ %{}) do
    fields = Answer.__schema__(:fields)

    model
    |> cast(attrs, fields)
    |> validate_required([:answer])
  end
end
