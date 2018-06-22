defmodule FirestormWeb.Forums.Watch do
  @moduledoc """
  A `Watch` is a polymorphic representation that a user is watching a thing in our system.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "abstract table: watches" do
    # This will be used by associations on each "concrete" table
    field(:assoc_id, :integer)
    field(:user_id, :integer)

    timestamps()
  end

  def changeset(%__MODULE__{} = watch, attrs) do
    watch
    |> cast(attrs, [:assoc_id, :user_id])
    |> validate_required([:assoc_id, :user_id])
  end
end
