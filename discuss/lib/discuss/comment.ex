defmodule Discuss.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :content, :string
    belongs_to :user, Discuss.User
    belongs_to :topic, Discuss.Topic

    timestamps()
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:content, :user_id, :topic_id])
    |> validate_required([:content, :user_id, :topic_id])
  end
end