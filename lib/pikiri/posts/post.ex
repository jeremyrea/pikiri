defmodule Pikiri.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import PolymorphicEmbed

  alias Pikiri.Users.User
  alias Pikiri.Posts.Image
  alias Pikiri.Posts.Text

  schema "posts" do
    belongs_to :user, User

    polymorphic_embeds_one :content,
      types: [
        text: [module: Text, identify_by_fields: [:text]],
        image: [module: Image, identify_by_fields: [:photo]]
      ],
      on_type_not_found: :raise,
      on_replace: :update

    timestamps()
  end

  def changeset(post_or_changeset, attrs \\ %{}) do
    post_or_changeset
    |> cast(attrs, [:user_id])
    |> assoc_constraint(:user)
    |> cast_polymorphic_embed(:content, required: true)
  end
end