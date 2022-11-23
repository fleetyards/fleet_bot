defmodule FleetBot.Discord.Fleetyards do
  alias Nostrum.Api

  use FleetBot.Discord.Command
  use FleetBot.Gettext
  alias FleetBot.Repo.Discord.FleetyardsAccount

  @impl Command
  def command("fleetyards", interaction) do
    Api.create_interaction_response(
      interaction,
      create_interaction_response(
        :deferred_channel_message_with_source,
        create_interaction_response_data(flags: :ephemeral)
      )
    )

    FleetBot.Discord.get_subcommand_name(interaction)
    |> fleetyards_command(interaction)
  end

  def fleetyards_command("link", interaction) do
    Api.edit_interaction_response(
      interaction,
      create_interaction_response_data(content: "todo", flags: :ephemeral)
    )
  end

  def fleetyards_command("unlink", %Nostrum.Struct.Interaction{user: user} = interaction) do
    FleetyardsAccount.get_account(user)
    |> int_fleetyards_unlink(interaction)
  end

  @impl Command
  def global_commands do
    [
      create_command("fleetyards", "Fleetyards account management",
        member_permission: :SEND_MESSAGES,
        dm_permission: true,
        options: [
          create_option("link", "Link Fleetyards account",
            type: :sub_command,
            channel_types: [:guild_text, :dm, :guild_directory],
            options: [
              create_option("token", "Fleetyards access token", type: :string),
              create_option("username", "Fleetyards username or email address", type: :string),
              create_option("password", "Fleetyards password", type: :string)
            ]
          ),
          create_option("unlink", "Unlink Fleetyards accounts",
            type: :sub_command,
            channel_types: [:guild_text, :dm, :guild_directory]
          )
        ]
      )
    ]
  end

  # Internal helpers
  defp int_fleetyards_unlink(nil, interaction) do
    content = LGettext.dgettext("discord_fleetyards", "Account not linked, cannot unlink.")
    Api.edit_interaction_response(interaction, create_interaction_response_data(content: content))
  end

  defp int_fleetyards_unlink(account, interaction) do
  end
end
