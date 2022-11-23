defmodule FleetBot.Repo.Migrations.AddDiscordCommandsManager do
  use Ecto.Migration

  def change do
    create table(:discord_commands) do
      add :command, :string, null: false
      add :command_id, :bigint
      add :guild_id, :bigint
      add :cmd_hash, :integer, null: false
    end

    create unique_index(:discord_commands, [:command, :guild_id])
    create unique_index(:discord_commands, [:command_id])
  end
end
