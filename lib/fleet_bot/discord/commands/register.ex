defmodule FleetBot.Discord.Commands.Register do
  alias Hex.API.Key
  use Bitwise, only_operators: true

  ## Callback interface
  @callback global_commands() :: [Nostrum.Struct.ApplicationCommand.application_command_map()]

  @callback delete_global_commands() :: [String.t()]

  @optional_callbacks delete_global_commands: 0

  ### Helper macros
  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)
      alias unquote(__MODULE__)
      require unquote(__MODULE__)

      import unquote(__MODULE__)

      require FleetBot.Gettext
    end
  end

  # def localization_dict(key) do
  #  locales = Gettext.known_locales(FGettext)
  #  |> Stream.map(fn lang ->
  #    Gettext.with_locale(lang, fn ->
  #      {lang, FGettext.dgettext("discord::commands", key)}
  #    end)
  #  end)
  #  |> Enum.into(%{})
  # end
  defmacro localization_dict(key) do
    langs = Application.fetch_env!(:fleet_bot, FleetBot.Discord)[:discord_allowed_langs]

    quote do
      Gettext.known_locales(FleetBot.Gettext)
      |> Stream.filter(fn lang ->
        Enum.member?(unquote(langs), lang)
      end)
      |> Stream.map(fn lang ->
        Gettext.with_locale(lang, fn ->
          {lang, FleetBot.Gettext.dgettext("discord::commands", unquote(key))}
        end)
      end)
      |> Enum.into(%{})
    end
  end

  defmacro create_command(name, description, opts \\ []) do
    extra =
      Keyword.get(opts, :extra, %{})
      |> Macro.escape()

    type =
      Keyword.get(opts, :type, :chat_input)
      |> command_input_type()

    options =
      if type == 1 do
        Keyword.get(opts, :options, [])
      else
        nil
      end

    default_member_permissions =
      Keyword.get(opts, :member_permission)
      |> default_member_permission_conv()

    dm_permission = Keyword.get(opts, :dm_permission)

    quote do
      Map.merge(unquote(extra), %{
        type: unquote(type),
        name: unquote(name),
        name_localizations: localization_dict(unquote(name)),
        description: unquote(description),
        description_localizations: localization_dict(unquote(description)),
        options: unquote(options),
        default_member_permissions: unquote(default_member_permissions),
        dm_permission: unquote(dm_permission)
      })
    end
  end

  defmacro create_option(name, description, opts \\ []) do
    extra =
      Keyword.get(opts, :extra, %{})
      |> Macro.escape()

    required = Keyword.get(opts, :required, nil)

    type =
      Keyword.get(opts, :type)
      |> command_option_type()

    choices = Keyword.get(opts, :choices)
    options = Keyword.get(opts, :options)

    channel_types =
      Keyword.get(opts, :channel_types)
      |> command_channel_types()

    min_value = Keyword.get(opts, :min_value)
    max_value = Keyword.get(opts, :max_value)
    min_length = Keyword.get(opts, :min_length)
    max_length = Keyword.get(opts, :max_length)
    autocomplete = Keyword.get(opts, :autocomplete)

    quote do
      Map.merge(unquote(extra), %{
        type: unquote(type),
        name: unquote(name),
        name_localizations: localization_dict(unquote(name)),
        description: unquote(description),
        description_localizations: localization_dict(unquote(description)),
        required: unquote(required),
        choices: unquote(choices),
        options: unquote(options),
        channel_types: unquote(channel_types),
        min_value: unquote(min_value),
        max_value: unquote(max_value),
        min_length: unquote(min_length),
        max_length: unquote(max_length),
        autocomplete: unquote(autocomplete)
      })
    end
  end

  defmacro create_choice(name, value, opts \\ []) do
    extra =
      Keyword.get(opts, :extra, %{})
      |> Macro.escape()

    quote do
      Map.merge(unquote(extra), %{
        name: unquote(name),
        name_localizations: localization_dict(unquote(name)),
        value: unquote(value)
      })
    end
  end

  ### Private macro helpers
  defp command_input_type(:chat_input), do: 1
  defp command_input_type(:user), do: 2
  defp command_input_type(:message), do: 3
  defp command_input_type(v) when is_integer(v), do: v

  defp default_member_permission_conv(v) when is_binary(v), do: v
  defp default_member_permission_conv(v) when is_integer(v), do: Integer.to_string(v)
  defp default_member_permission_conv(:VIEW_CHANNEL), do: 1 <<< 10
  defp default_member_permission_conv(:SEND_MESSAGES), do: 1 <<< 11

  defp command_option_type(:sub_command), do: 1
  defp command_option_type(:sub_command_group), do: 2
  defp command_option_type(:string), do: 3
  defp command_option_type(:integer), do: 4
  defp command_option_type(:boolean), do: 5
  defp command_option_type(:user), do: 6
  defp command_option_type(:channel), do: 7
  defp command_option_type(:role), do: 8
  defp command_option_type(:mentionable), do: 9
  defp command_option_type(:number), do: 10
  defp command_option_type(:attachment), do: 11
  defp command_option_type(v) when is_number(v), do: v

  defp command_channel_types(nil), do: nil
  defp command_channel_types(v) when is_atom(v) or is_number(v), do: [command_channel_type(v)]

  defp command_channel_types(v) when is_list(v),
    do: Enum.map(v, fn v -> command_channel_type(v) end) |> Enum.into([])

  defp command_channel_type(:guild_text), do: 0
  defp command_channel_type(:dm), do: 1
  defp command_channel_type(:guild_voice), do: 2
  defp command_channel_type(:group_dm), do: 3
  defp command_channel_type(:guild_category), do: 4
  defp command_channel_type(:guild_announcement), do: 5
  defp command_channel_type(:announcement_thread), do: 10
  defp command_channel_type(:public_thread), do: 11
  defp command_channel_type(:private_thread), do: 12
  defp command_channel_type(:guild_stage_voice), do: 13
  defp command_channel_type(:guild_directory), do: 14
  defp command_channel_type(:guild_forum), do: 15
  defp command_channel_type(v) when is_number(v), do: v
  # TODO: import all from https://discord.com/developers/docs/topics/permissions and allow arrays
end
