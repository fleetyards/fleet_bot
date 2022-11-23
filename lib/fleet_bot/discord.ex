defmodule FleetBot.Discord do
  @moduledoc """
  Discord High level helper functions.
  """
  import Ecto.Changeset

  @spec chat_command_allowed_regex() :: Regex.t()
  @moduledoc """
  Regex matcher for the discord allowed command string.

  Converted from discords `^[-_\p{L}\p{N}\p{sc=Deva}\p{sc=Thai}]{1,32}$` Regex.

  See: https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-naming
  """
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

  use Nostrum.Consumer

  def start_link, do: Consumer.start_link(__MODULE__)

  @impl Nostrum.Consumer
  def handle_event({:READY, %{}, _ws_state}) do
    FleetBot.Discord.Commands.RegisterManager.set_ready()
    :noop
  end

  @impl true
  def handle_event(_event) do
    # event
    # |> IO.inspect()

    :noop
  end
end
