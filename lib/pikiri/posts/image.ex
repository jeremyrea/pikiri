defmodule Pikiri.Posts.Image do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :photo, Pikiri.Uploaders.PhotoUploader.Type
    field :caption, :string
    field :caption_rotation, :integer
  end

  def changeset(struct, params \\ :invalid) do
    IO.inspect params
    struct
    |> cast(params, [:caption, :caption_rotation])
    |> cast_attachments(params, [:photo])
    |> validate_length(:caption, max: 80)
    |> validate_number(:caption_rotation, greater_than_or_equal_to: -26, less_than_or_equal_to: 26)
    |> validate_required([:photo])
  end
end
