defmodule Pikiri.Posts.Text do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :text, :string
  end

  def changeset(struct, params \\ :invalid) do
    struct
    |> cast(params, [:text])
    |> validate_required([:text])
  end
end