defmodule FleetBot.Discord.Commands.RegisterManager do
  use FleetBot.Gettext

  alias FleetBot.Repo.Discord.Command

  ## Public Interface
  def set_ready() do
    register_global_commands()
    # FIXME: remove_global_commands()
  end

  def get_module(command), do: GenServer.call(__MODULE__, {:get_module, command})

  def register_global_commands(), do: GenServer.cast(__MODULE__, {:register_global})
  def register_global_command(module), do: GenServer.cast(__MODULE__, {:register_global, module})

  def remove_global_commands(), do: GenServer.cast(__MODULE__, {:remove_global})

  ## GenServer
  use GenServer

  def start_link(_opts \\ nil) do
    GenServer.start_link(__MODULE__, FleetBot.Discord.Commands, name: __MODULE__)
  end

  @impl GenServer
  def init(module) when is_atom(module) do
    command_modules =
      FleetBot.Discord.Commands.get_commands()
      |> Enum.map(&{&1, :none})

    {:ok, %{command_modules: command_modules, module_commands: %{}}}
  end

  @impl GenServer
  def handle_call({:get_module, command}, _from, %{module_commands: module_commands} = state) do
    {:reply, Map.get(module_commands, command), state}
  end

  @impl GenServer
  def handle_cast({:register_global}, %{command_modules: modules} = state) do
    state =
      Enum.reduce(modules, state, fn
        {module, :none}, state ->
          int_register_global_commands(module, state)

        _, state ->
          state
      end)

    LGettext.debug("Registered all global commands")

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:register_global, module}, state),
    do: {:noreply, int_register_global_commands(module, state)}

  @impl GenServer
  def handle_cast({:remove_global}, %{module: module} = state) do
    if Kernel.function_exported?(module, :delete_global_commands, 0) do
      # TODO: count errors/deletes/missing
      apply(module, :delete_global_commands, [])
      |> Stream.map(&remove_global_command/1)
      |> Stream.run()
    end

    {:noreply, state}
  end

  ## Internal Functions

  # region
  defp int_register_global_commands(
         module,
         %{command_modules: modules, module_commands: module_commands} = state
       ) do
    Keyword.get(modules, module)
    |> int_register_global_commands(module)
    |> case do
      {:global, commands} ->
        modules = Keyword.put(modules, module, :global)

        commands =
          commands
          |> Enum.map(&{&1, module})
          |> Enum.into(%{})
          |> Map.merge(module_commands)

        state
        |> Map.put(:command_modules, modules)
        |> Map.put(:module_commands, commands)

      v when is_atom(v) ->
        modules = Keyword.put(modules, module, :global)

        state
        |> Map.put(:command_modules, modules)

      _ ->
        state
    end
  end

  defp int_register_global_commands(:none, module) when is_atom(module) do
    int_register_global_commands_module(module)
  end

  defp int_register_global_commands(nil, module) when is_atom(module) do
    LGettext.error("Module `%{module}` not found, cannot register commands", module: module)
    nil
  end

  defp int_register_global_commands(:global, module) when is_atom(module) do
    LGettext.debug("Global commands for `%{module}` already registered", module: module)
    nil
  end

  defp int_register_global_commands_module(module) when is_atom(module) do
    LGettext.debug("Initializing global commands: %{module}", module: module)

    # TODO: count knowns/errors/inserts
    commands =
      apply(module, :global_commands, [])
      |> Stream.map(&int_register_global_command/1)
      |> Stream.filter(fn
        {_, {:ok, _}} -> true
        _ -> false
      end)
      |> Enum.into([])

    commands_num =
      commands
      |> Enum.count()

    commands =
      commands
      |> Enum.map(fn {name, _} -> name end)

    LGettext.info("Global commands initialized (%{module}): %{num}",
      module: module,
      num: commands_num
    )

    # Logger.info("Global commands initialized")
    # return nil on error
    {:global, commands}
  end

  @spec int_register_global_command(Nostrum.Struct.ApplicationCommand.application_command_map()) ::
          nil | :ok
  defp int_register_global_command(%{name: name} = command) do
    old_command = Command.get_command(name)

    hash = :erlang.phash2(command)

    int_register_global_command(command, old_command, hash)
  end

  defp int_register_global_command(command, nil, hash) do
    # Create new command
    int_commit_global_command(command, hash)
  end

  defp int_register_global_command(
         %{name: name} = command,
         %{cmd_hash: old_hash} = old_command,
         hash
       ) do
    # Update old command
    if hash == old_hash do
      LGettext.debug(
        "Global Command `%{name}` already correctly registerd, skipping.",
        name: name
      )

      {name, {:ok, :known}}
    else
      int_update_global_command(command, old_command, hash)
    end
  end

  defp int_commit_global_command(%{} = command, hash) do
    with {:ok, %{id: command_id, name: name}} <-
           Nostrum.Api.create_global_application_command(command) do
      LGettext.info("Registering Global Command `%{name}`", name: name)

      {name, Command.add_command(name, command_id, hash)}
    else
      {:error, e} ->
        {:error, e}
    end
  end

  defp int_update_global_command(%{} = command, %{command_id: old_id} = old_command, hash) do
    Nostrum.Api.edit_global_application_command(old_id, command)
    |> case do
      {:ok, %{id: command_id, name: name}} ->
        LGettext.info("Updating Global Command `%{name}`", name: name)

        {name, Command.update_command(old_command, hash, command_id)}

      e ->
        e
    end
  end

  # endregion

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
end
