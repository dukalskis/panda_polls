defmodule Poll.Model do
  defmacro __using__(_) do
    parent = __MODULE__

    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias unquote(parent)
      alias __MODULE__
      alias Poll.Repo

      @primary_key {:id, UUIDv7, autogenerate: true}

      @foreign_key_type UUIDv7
    end
  end
end
