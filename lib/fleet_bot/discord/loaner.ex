defmodule FleetBot.Discord.Loaner do
  alias Nostrum.Api
  use FleetBot.Discord.Command
  use FleetBot.Gettext
  alias FleetBot.Fleetyards.Models

  @task_sup FleetBot.Discord.LoanerSupervisor

  # Loaner website
  @impl Command
  def command(
        "loaner",
        %Nostrum.Struct.Interaction{
          data: %Nostrum.Struct.ApplicationCommandInteractionData{options: nil}
        } = interaction
      ) do
    Api.create_interaction_response!(
      interaction,
      create_interaction_response(
        :channel_message_with_source,
        create_interaction_response_data(
          embeds: [
            %{
              type: "rich",
              title: "Loaner Ship Matrix",
              description:
                "Have you found yourself in possession of a pledge with a ship that's not yet Flight Ready? We've got you covered, providing you with a loaner ship to ensure that you are able to fly inside the curr...",
              color: 0x000000,
              thumbnail: %{
                url:
                  "https://theme.zdassets.com/theme_assets/290051/27ade7046aed8d53592dbc33c4d47e876b366f37.png",
                height: 0,
                width: 0
              },
              footer: %{
                text: "Roberts Space Industries Knowledge Base",
                icon_url:
                  "https://theme.zdassets.com/theme_assets/290051/27ade7046aed8d53592dbc33c4d47e876b366f37.png"
              },
              url:
                "https://support.robertsspaceindustries.com/hc/en-us/articles/360003093114-Loaner-Ship-Matrix"
            }
          ]
        )
      )
    )
  end

  # Autocompletion
  @impl Command
  def command(
        "loaner",
        %Nostrum.Struct.Interaction{
          data: %Nostrum.Struct.ApplicationCommandInteractionData{
            options: [
              %Nostrum.Struct.ApplicationCommandInteractionDataOption{focused: true, value: value}
            ]
          }
        } = interaction
      ) do
    Api.create_interaction_response!(
      interaction,
      create_interaction_response(
        :application_command_autocomplete_result,
        %{
          choices: Models.get_discord_slug_choices(value)
        }
        # create_interaction_response_data()
      )
    )
  end

  # gives
  @impl Command
  def command(
        "loaner",
        %Nostrum.Struct.Interaction{
          token: interaction_token,
          data: %Nostrum.Struct.ApplicationCommandInteractionData{
            options: [
              %Nostrum.Struct.ApplicationCommandInteractionDataOption{
                focused: nil,
                name: "ship",
                value: slug
              }
            ]
          }
        } = interaction
      ) do
    Api.create_interaction_response!(
      interaction,
      create_interaction_response(
        :deferred_channel_message_with_source,
        create_interaction_response_data()
      )
    )

    Task.Supervisor.async_nolink(@task_sup, __MODULE__, :search, [interaction_token, slug, :gives])
  end

  # @impl Command
  # def command("loaner", interaction) do
  #  IO.inspect(interaction)

  #  Api.create_interaction_response!(
  #    interaction,
  #    create_interaction_response(
  #      :deferred_channel_message_with_source,
  #      create_interaction_response_data(flags: :ephemeral)
  #    )
  #  )

  #  Api.edit_interaction_response!(interaction, create_interaction_response_data(content: "todo"))
  # end

  @impl Command
  def global_commands do
    [
      create_command("loaner", "Star Citizen Loaner informations",
        member_permissions: :send_message,
        dm_permission: true,
        options: [
          create_option("ship", "Conceptship that gives loaners",
            type: :string,
            min_lenght: 2,
            autocomplete: true
          )
          # create_option("gets", "Ship that is given by concept ship",
          #  type: :string,
          #  min_length: 2,
          #  autocompelte: true
          # )
        ]
      )
    ]
  end

  ## Internal functions
  # gives task
  def search(interaction_token, slug, :gives) do
    Models.model(slug)
    |> case do
      {:ok, model} ->
        Api.edit_interaction_response!(interaction_token, format_loaners(model, :gives))

      {:error, :not_found} ->
        Api.edit_interaction_response!(
          interaction_token,
          create_interaction_response_data(content: "Ship `%{slug}` not found", slug: slug)
        )
    end
  end

  def format_loaners(%{"loaners" => [], "name" => name}, :gives) do
    create_interaction_response_data(
      content: "Ship `%{name}` does not provide any loaners",
      name: name
    )
  end

  def format_loaners(%{"loaners" => loaners, "name" => name}, :gives) do
    embeds =
      loaners
      |> Enum.map(&Task.Supervisor.async_nolink(@task_sup, __MODULE__, :format_loaner, [&1]))
      |> Task.yield_many(5_000)
      |> Enum.filter(fn
        {_, {:ok, _}} -> true
        _ -> false
      end)
      |> Enum.take(10)
      |> Enum.map(fn {_, {:ok, v}} -> v end)

    create_interaction_response_data(
      embeds: embeds,
      content: "Ship `%{name}` provides the following loaners:",
      name: name
    )
  end

  def format_loaner(%{"name" => name, "slug" => slug}) do
    Models.model(slug)
    |> case do
      {:ok, model} ->
        %{
          type: "rich",
          title: Map.get(model, "name"),
          description: Map.get(model, "description"),
          # TODO: get color based on ship size
          color: 0,
          image: %{
            url: Map.get(model, "storeImageMedium")
          },
          author: %{
            name: Map.get(model, "manufacturer") |> Map.get("name")
          },
          url: Map.get(model, "links") |> Map.get("frontend")
        }

      _ ->
        %{
          type: "rich",
          title: name
        }
    end
  end
end
