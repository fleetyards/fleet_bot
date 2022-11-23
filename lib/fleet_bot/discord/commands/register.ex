defmodule FleetBot.Discord.Commands.Register do
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

      import unquote(__MODULE__),
        only: [create_command: 2, create_command: 3, localization_dict: 1]

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
    type = :todo

    quote do
      Map.merge(unquote(extra), %{
        type: unquote(type),
        name: unquote(name),
        name_localizations: localization_dict(unquote(name)),
        description: unquote(description),
        description_localizations: localization_dict(unquote(description)),
        required: unquote(required)
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
  # TODO: import all from https://discord.com/developers/docs/topics/permissions and allow arrays
end
