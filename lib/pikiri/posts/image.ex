defmodule Pikiri.Posts.Image do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :photo, Pikiri.Uploaders.PhotoUploader.Type
    field :caption, :string
  end

  def changeset(struct, params \\ :invalid) do
    IO.inspect params
    struct
    |> cast(params, [:caption])
    |> cast_attachments(params, [:photo])
    |> validate_length(:caption, max: 80)
    |> validate_required([:photo])
  end
end
