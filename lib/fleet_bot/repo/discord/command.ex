defmodule FleetBot.Repo.Discord.Command do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias FleetBot.Repo
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
    field :cmd_hash, :integer
  end

  ## Api
  def add_command(%{name: name} = command, command_id) do
    hash = :erlang.phash2(command)
    guild_id = Map.get(command, :guild_id)

    add_command(name, guild_id, command_id, hash)
  end

  def add_command(command, guild_id \\ nil, command_id, cmd_hash)
      when is_binary(command) and is_integer(cmd_hash) do
    create_changeset(%{
      command: command,
      guild_id: guild_id,
      command_id: command_id,
      cmd_hash: cmd_hash
    })
    |> Repo.insert()
  end

  def update_command(command, hash, command_id) do
    update_changeset(command, %{cmd_hash: hash, command_id: command_id})
    |> Repo.update()
  end

  def delete_command(command) when is_binary(command) do
    get_command(command)
    |> delete_command()
  end

  def delete_command(%__MODULE__{} = command) do
    Repo.delete(command)
  end

  def get_command(name, guild_id \\ nil)

  def get_command(name, nil) when is_binary(name) do
    query = from m in __MODULE__, where: is_nil(m.guild_id) and m.command == ^name, select: m

    Repo.one(query)
  end

  def get_command(name, guild_id) when is_binary(name) and is_integer(guild_id) do
    Repo.get_by(__MODULE__, name: name, guild_id: guild_id)
  end

  ## Changeset
  def create_changeset(command \\ %__MODULE__{}, attrs) do
    command
    |> cast(attrs, [:command, :command_id, :guild_id, :cmd_hash])
    |> validate_command()
    |> unique_constraint(:command_id)
    |> Discord.validate_snowflake(:command_id, required: false)
    |> Discord.validate_snowflake(:guild_id, required: false)
    |> validate_hash()
  end

  def update_changeset(command, attrs) do
    command
    |> cast(attrs, [:command_id, :cmd_hash])
    |> unique_constraint(:command_id)
    |> Discord.validate_snowflake(:command_id, required: false)
    |> validate_hash()
  end

  ## Validators
  defp validate_command(changeset) do
    changeset
    |> unique_constraint([:command, :guild_id])
    |> validate_length(:command, min: 1, max: 32)
    |> validate_format(:command, Discord.chat_command_allowed_regex())
  end

  defp validate_hash(changeset) do
    changeset
    |> validate_required(:cmd_hash)
    |> validate_number(:cmd_hash, greater_than: 0)
  end
end
