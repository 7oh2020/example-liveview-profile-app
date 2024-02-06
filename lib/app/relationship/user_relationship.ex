defmodule App.Relationship.UserRelationship do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_relationship" do
    belongs_to :source_user, App.Accounts.User
    belongs_to :target_user, App.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_relationship, attrs) do
    user_relationship
    |> cast(attrs, [:source_user_id, :target_user_id])
    |> validate_required([:source_user_id, :target_user_id])
  end
end
