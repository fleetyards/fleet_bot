defmodule FleetBot.Discord do
  @moduledoc """
  Discord High level helper functions.
  """
  import Ecto.Changeset

  @spec chat_command_allowed_regex() :: Regex.t()
  @doc """
  Regex matcher for the discord allowed command string.

  Converted from discords `^[-_\p{L}\p{N}\p{sc=Deva}\p{sc=Thai}]{1,32}$` Regex.

  See: https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-naming
  """
  alias FleetBot.Discord.Commands.RegisterManager
  alias Nostrum.Consumer
  def chat_command_allowed_regex, do: ~R/^[-_\p{L}\p{N}\p{Devanagari}\p{Thai}]{1,32}$/u

  @spec validate_snowflake(Ecto.Changeset.t(), atom, Keyword.t()) :: Ecto.Changeset.t()
  @doc """
  Validates a change is a `snowflake`.

  ## Options

    * `:message` - the message on failure, defaults to "not a snowflake"
    * `:required` - the snowflake is required to exist

  ## Examples

      validate_snowflake(changeset, :guild_id)
  """
  def validate_snowflake(changeset, field, opts \\ []) do
    message = Keyword.get(opts, :message, "not a snowflake")

    changeset =
      changeset
      |> validate_number(field,
        greater_than_or_equal_to: 0,
        less_than_or_equal_to: 18_446_744_073_709_551_615,
        message: message
      )

    if Keyword.get(opts, :required, true),
      do: validate_required(changeset, field),
      else: changeset
  end

  @doc """
  Get name of subcomand nested in interaction or option.

  ## Example

      iex> get_subcommand_name(%Nostrum.Struct.ApplicationCommandInteractionDataOption{name: "foo"})
      "foo"

      iex> get_subcommand_name(%Nostrum.Struct.ApplicationCommandInteractionData{options: [
      ...>   %Nostrum.Struct.ApplicationCommandInteractionDataOption{name: "bar"}
      ...> ]})
      "bar"
  """
  def get_subcommand_name(interaction)

  @spec get_subcommand_name(Nostrum.Struct.Interaction.t()) :: String.t()
  def get_subcommand_name(%Nostrum.Struct.Interaction{data: data}), do: get_subcommand_name(data)

  @spec get_subcommand_name(Nostrum.Struct.ApplicationCommandInteractionData.t()) :: String.t()
  def get_subcommand_name(%Nostrum.Struct.ApplicationCommandInteractionData{options: options}),
    do: get_subcommand_name(options)

  @spec get_subcommand_name(
          [Nostrum.Struct.ApplicationCommandInteractionDataOption.t()]
          | Nostrum.Struct.ApplicationCommandInteractionDataOption.t()
        ) :: String.t()
  def get_subcommand_name([option | _]), do: get_subcommand_name(option)

  def get_subcommand_name(%Nostrum.Struct.ApplicationCommandInteractionDataOption{name: name}),
    do: name

  ## Consumer impl
  use Nostrum.Consumer
  use FleetBot.Gettext

  def start_link, do: Consumer.start_link(__MODULE__)

  @impl Nostrum.Consumer
  def handle_event({:READY, %{}, _ws_state}) do
    FleetBot.Discord.Commands.RegisterManager.set_ready()
    :noop
  end

  @impl Nostrum.Consumer
  def handle_event(
        {:INTERACTION_CREATE,
         %Nostrum.Struct.Interaction{
           data: %Nostrum.Struct.ApplicationCommandInteractionData{name: name}
         } = interaction, _ws_state}
      )
      when is_binary(name) do
    :telemetry.span([:fleet_bot, :discord, :handle_event, :interaction], %{command: name}, fn ->
      RegisterManager.get_module(name)
      |> case do
        module when is_atom(module) ->
          # TODO: move onto task
          apply(module, :command, [name, interaction])
          |> case do
            :ok ->
              {:ok, %{command: name}}

            {:ok} ->
              {:ok, %{command: name}}

            {:ok, _} ->
              {:ok, %{command: name}}

            {:error, e} ->
              {:error, %{message: e}}
          end

        nil ->
          LGettext.error("No module found for command `%{command}`", command: name)
          {:error, %{message: "no module found"}}
      end
    end)

    :ok
  end

  @impl true
  def handle_event(_event) do
    # event
    # |> IO.inspect()

    :noop
  end
end
