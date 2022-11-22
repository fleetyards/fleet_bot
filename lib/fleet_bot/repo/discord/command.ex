defmodule FleetBot.Repo.Discord.Command do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias FleetBot.Discord

  @type t() :: %__MODULE__{
          command: String.t(),
          command_id: Nostrum.Snowflake.t() | nil,
          guild_id: Nostrum.Snowflake.t() | nil
        }

  schema "discord_commands" do
    field :command, :string
    field :command_id, :integer
    field :guild_id, :integer
  end

  def create_changeset(command \\ %__MODULE__{}, attrs) do
    command
    |> cast(attrs, [:command, :command_id, :guild_id])
    |> validate_command()
    |> Discord.validate_snowflake(:command_id, required: false)
    |> Discord.validate_snowflake(:guild_id, required: false)
  end

  defp validate_command(changeset) do
    changeset
    |> unique_constraint(:command)
    |> validate_length(:command, min: 1, max: 32)
    |> validate_format(:command, Discord.chat_command_allowed_regex())
  end
end
