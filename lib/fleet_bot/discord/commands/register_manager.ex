defmodule FleetBot.Discord.Commands.RegisterManager do
  use FleetBot.Gettext

  alias FleetBot.Repo.Discord.Command

  ## Public Interface
  def set_ready() do
    register_global_commands()
    remove_global_commands()
  end

  def register_global_commands(), do: GenServer.cast(__MODULE__, {:register_global})

  def remove_global_commands(), do: GenServer.cast(__MODULE__, {:remove_global})

  ## GenServer
  use GenServer

  def start_link(_opts \\ nil) do
    GenServer.start_link(__MODULE__, FleetBot.Discord.Commands, name: __MODULE__)
  end

  @impl GenServer
  def init(module) when is_atom(module) do
    {:ok, %{module: module}}
  end

  @impl GenServer
  def handle_cast({:register_global}, state), do: {:noreply, register_global_commands(state)}

  def handle_cast({:remove_global}, %{module: module} = state) do
    if Kernel.function_exported?(module, :delete_global_commands, 0) do
      # TODO: count errors/deletes/missing
      apply(module, :delete_global_commands, [])
      |> Stream.map(&remove_global_command/1)
      |> Enum.into([])
    end

    {:noreply, state}
  end

  ## Internal Functions

  # region
  def remove_global_command(name) when is_binary(name),
    do: remove_global_command(Command.get_command(name))

  def remove_global_command(%Command{command_id: id, command: name} = command) do
    with {:ok} <- Nostrum.Api.delete_global_application_command(id),
         {:ok, _} = v <- Command.delete_command(command) do
      LGettext.info("Deleted global command: `%{name}", name: name)
      v
    else
      {:error, _} = e -> e
    end
  end

  # endregion

  # region
  def register_global_commands(%{globale_init: true} = state) do
    LGettext.debug("Global commands already initialized")
    state
  end

  def register_global_commands(%{module: module} = state) do
    LGettext.debug("Initializing global commands")

    # TODO: count knowns/errors/inserts
    commands_num =
      apply(module, :global_commands, [])
      |> Stream.map(&register_global_command/1)
      |> Enum.into([])
      |> Enum.count()

    LGettext.info("Global commands initialized: %{num}", num: commands_num)

    # Logger.info("Global commands initialized")
    Map.put(state, :global_init, true)
  end

  @spec register_global_command(Nostrum.Struct.ApplicationCommand.application_command_map()) ::
          nil | :ok
  def register_global_command(%{name: name} = command) do
    old_command = Command.get_command(name)

    hash = :erlang.phash2(command)

    register_global_command(command, old_command, hash)
  end

  def register_global_command(command, nil, hash) do
    # Create new command
    commit_global_command(command, hash)
  end

  def register_global_command(%{name: name} = command, %{cmd_hash: old_hash} = old_command, hash) do
    # Update old command
    if hash == old_hash do
      LGettext.debug(
        "Global Command `%{name}` already correctly registerd, skipping.",
        name: name
      )

      {:ok, :known}
    else
      update_global_command(command, old_command, hash)
    end
  end

  defp commit_global_command(%{} = command, hash) do
    with {:ok, %{id: command_id, name: name}} <-
           Nostrum.Api.create_global_application_command(command) do
      LGettext.info("Registering Global Command `%{name}`", name: name)

      Command.add_command(name, command_id, hash)
    else
      {:error, e} ->
        {:error, e}
    end
  end

  defp update_global_command(%{} = command, %{command_id: old_id} = old_command, hash) do
    with {:ok, %{id: command_id, name: name}} <-
           Nostrum.Api.edit_global_application_command(old_id, command) do
      LGettext.info("Updating Global Command `%{name}`", name: name)

      Command.update_command(old_command, hash, command_id)
    else
      {:error, _} = e -> e
    end
  end

  # endregion
end
