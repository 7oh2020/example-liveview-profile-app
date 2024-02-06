defmodule App.Repo.Migrations.CreateUserRelationship do
  use Ecto.Migration

  def change do
    create table(:user_relationship) do
      add :source_user_id, references(:users, on_delete: :delete_all), null: false
      add :target_user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_relationship, [:source_user_id])
    create index(:user_relationship, [:target_user_id])
    create unique_index(:user_relationship, [:source_user_id, :target_user_id])
  end
end
