defmodule FleetBot.Discord.Fleet do
  alias Nostrum.Api
  use FleetBot.Discord.Command
  use FleetBot.Gettext
  alias FleetBot.Fleetyards.Fleets

  @task_sup FleetBot.Discord.FleetSupervisor

  @impl Command
  def global_commands do
    [
      create_command("fleet", "Fleetyards fleets info",
        member_permissions: :send_message,
        dm_permission: true,
        options: [
          create_option("info", "Show fleet informations",
            type: :sub_command,
            options: [
              create_option("fleet", "Fleet to show",
                type: :string,
                required: true
              )
            ]
          )
        ]
      )
    ]
  end

  @impl Command
  def command(
        "fleet",
        %Nostrum.Struct.Interaction{
          data: %Nostrum.Struct.ApplicationCommandInteractionData{
            options: [
              %Nostrum.Struct.ApplicationCommandInteractionDataOption{
                name: "info",
                options: [
                  %Nostrum.Struct.ApplicationCommandInteractionDataOption{
                    name: "fleet",
                    value: fleet
                  }
                ]
              }
            ]
          }
        } = interaction
      ) do
    Api.create_interaction_response!(
      interaction,
      create_interaction_response(:deferred_channel_message_with_source)
    )

    Fleets.info(fleet)
    |> case do
      {:ok, fleet} ->
        embed = %{
          type: "rich",
          title: Map.get(fleet, "name"),
          url: Map.get(fleet, "homepage") |> fix_url,
          description: Map.get(fleet, "description")
        }

        embed =
          if Map.get(fleet, "logo") != nil do
            Map.put(embed, "thumbnail", %{
              url: Map.get(fleet, "logo")
            })
          else
            embed
          end

        components_social =
          add_component([], "Discord", Map.get(fleet, "discord"))
          |> add_component("Guilded", Map.get(fleet, "guilded"))
          |> add_component("Teamspeak", Map.get(fleet, "ts"))
          |> IO.inspect()

        components_web =
          add_component([], "Twitch", Map.get(fleet, "twitch"))
          |> add_component("Youtube", Map.get(fleet, "youtube"))
          |> IO.inspect()

        components =
          if components_social != [] do
            [%{type: 1, components: components_social}]
          else
            []
          end

        components =
          if components_web != [] do
            components ++
              [
                %{
                  type: 1,
                  components: components_web
                }
              ]
          else
            components
          end
          |> IO.inspect()

        Api.edit_interaction_response!(
          interaction,
          create_interaction_response_data(
            embeds: [embed],
            components: components
          )
        )

      {:error, :not_found} ->
        Api.edit_interaction_response!(
          interaction,
          create_interaction_response_data(content: "Fleet not found")
        )
    end
  end

  defp fix_url(nil), do: nil

  defp fix_url(url) when is_binary(url) do
    if String.starts_with?(url, "http") do
      url
    else
      "https://" <> url
    end
  end

  defp add_component(list, _name, nil), do: list

  defp add_component(list, name, url) do
    list ++ [create_component(name, url)]
  end

  defp create_component(name, url) do
    %{
      style: 5,
      type: 2,
      label: name,
      url: fix_url(url),
      disabled: false
    }
  end
end
