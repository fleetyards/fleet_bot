defmodule FleetBot.DiscordTest.Schema do
  use Ecto.Schema
  import Ecto.Changeset

  schema "test" do
    field :snowflake, :integer
  end

  def changeset(snowflake, opts \\ []) do
    %__MODULE__{}
    |> cast(%{snowflake: snowflake}, [:snowflake])
    |> FleetBot.Discord.validate_snowflake(:snowflake, opts)
  end
end

defmodule FleetBot.DiscordTest do
  use ExUnit.Case, async: true
  doctest FleetBot.Discord, import: true

  describe "validate snowflake" do
    alias FleetBot.DiscordTest.Schema

    test "valid snowflake required" do
      changeset = Schema.changeset(123, required: true)

      assert changeset.valid?
    end

    test "valid snowflake required missing" do
      changeset = Schema.changeset(nil, required: true)

      assert !changeset.valid?
    end

    test "invalid snowflake required" do
      changeset = Schema.changeset("foo", required: true)

      assert !changeset.valid?
      assert changeset.errors == [snowflake: {"is invalid", [type: :integer, validation: :cast]}]
    end
  end
end
