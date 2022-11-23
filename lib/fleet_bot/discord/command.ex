defmodule FleetBot.Discord.Command do
  @callback command(String.t(), %Nostrum.Struct.Interaction{}) :: term()

  @callback global_commands() :: [Nostrum.Struct.ApplicationCommand.application_command_map()]
  @callback remove_global_commands() :: [String.t()]

  @optional_callbacks global_commands: 0, remove_global_commands: 0

  # Macros
  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)
      alias unquote(__MODULE__)
      require unquote(__MODULE__)

      import unquote(__MODULE__),
        only: [
          create_interaction_response: 1,
          create_interaction_response: 2,
          create_interaction_response_data: 1
        ]

      require FleetBot.Discord.Commands.Register
      import FleetBot.Discord.Commands.Register

      use FleetBot.Gettext
    end
  end

  defmacro create_interaction_response(type, data \\ nil) do
    type = interaction_response_type(type)

    quote do
      %{
        type: unquote(type),
        data: unquote(data)
      }
    end
  end

  def create_interaction_response_data(opts) do
    tts = Keyword.get(opts, :tts)
    content = Keyword.get(opts, :content)
    embeds = Keyword.get(opts, :embeds)
    allowed_mentions = Keyword.get(opts, :allowed_mentions)

    flags =
      Keyword.get(opts, :flags)
      |> interaction_response_data_flags()

    components = Keyword.get(opts, :components)
    attachements = Keyword.get(opts, :attachements)

    # quote do
    #  %{
    #    tts: unquote(tts),
    #    content: unquote(
    #      content
    #    ),
    #    embeds: unquote(embeds),
    #    allowed_mentions: unquote(allowed_mentions),
    #    flags: unquote(flags),
    #    components: unquote(components),
    #    attachements: unquote(attachements)
    #  }
    # end
    %{
      tts: tts,
      content: content,
      embeds: embeds,
      allowed_mentions: allowed_mentions,
      flags: flags,
      components: components,
      attachements: attachements
    }
  end

  ## Macro helpers
  use Bitwise, only_operators: true

  def interaction_response_type(:pong), do: 1
  def interaction_response_type(:channel_message_with_source), do: 4
  def interaction_response_type(:deferred_channel_message_with_source), do: 5
  def interaction_response_type(:deferred_update_channel), do: 6
  def interaction_response_type(:update_message), do: 7
  def interaction_response_type(:application_command_autocomplete_result), do: 8
  def interaction_response_type(:modal), do: 9
  def interaction_response_type(v) when is_number(v), do: v

  def interaction_response_data_flags(flags) when is_list(flags) do
    flags
    |> Enum.map(&interaction_response_data_flags/1)
    |> Enum.reduce(0, fn flag, acc ->
      flag ||| acc
    end)
  end

  def interaction_response_data_flags(:suppress_embeds), do: 1 <<< 3
  def interaction_response_data_flags(:ephemeral), do: 1 <<< 6
  def interaction_response_data_flags(v) when is_number(v), do: v
end
