defmodule App.RelationshipFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Relationship` context.
  """

  @doc """
  Generate a user_relationship.
  """
  def user_relationship_fixture(attrs \\ %{}) do
    {:ok, user_relationship} =
      attrs
      |> Enum.into(%{})
      |> App.Relationship.create_user_relationship()

    user_relationship
  end
end
