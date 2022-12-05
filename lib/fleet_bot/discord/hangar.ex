defmodule FleetBot.Discord.Hangar do
  @moduledoc """
  Hangar command.

  ## Subcommands
  ### public

  Shows public hangar of user
  """
  alias FleetBot.Fleetyards
  alias Nostrum.Api
  use FleetBot.Discord.Command
  use FleetBot.Gettext
  alias FleetBot.Fleetyards.Vehicles

  @task_sup FleetBot.Discord.HangarSupervisor

  # public hangar
  @impl Command
  def command(
        "hangar",
        %Nostrum.Struct.Interaction{
          data: %Nostrum.Struct.ApplicationCommandInteractionData{
            options: [
              %Nostrum.Struct.ApplicationCommandInteractionDataOption{
                focused: nil,
                name: "public",
                options: args
              }
            ]
          }
        } = interaction
      ) do
    Task.Supervisor.async_nolink(@task_sup, __MODULE__, :public, [interaction, args])
    :ok
  end

  @impl Command
  def global_commands do
    [
      create_command("hangar", "Fleetyards Hangar managemant and viewing",
        member_permissions: :send_message,
        dm_permission: true,
        options: [
          create_option("public", "Show public hangar",
            type: :sub_command,
            options: [
              create_option("user", "Fleetyards user to query hangar",
                type: :string,
                # TODO: dont require, and get from own discord user <-> fleetyards user link
                required: true
              ),
              create_option("group", "Fleetyards hangar group to filter",
                type: :string,
                autocomplete: true
              )
            ]
          )
        ]
      )
    ]
  end

  # Internal functions
  def public(interaction, [
        %Nostrum.Struct.ApplicationCommandInteractionDataOption{name: "user", value: user},
        %Nostrum.Struct.ApplicationCommandInteractionDataOption{
          name: "group",
          value: group,
          focused: true
        }
      ]) do
    Api.create_interaction_response!(
      interaction,
      create_interaction_response(:application_command_autocomplete_result, %{
        choices: Vehicles.get_discord_group_choices(user, group)
      })
    )
  end

  def public(interaction, [%Nostrum.Struct.ApplicationCommandInteractionDataOption{focused: true}]) do
    Api.create_interaction_response!(
      interaction,
      create_interaction_response(:application_command_autocomplete_result, %{choices: []})
    )
  end

  def public(interaction, [
        %Nostrum.Struct.ApplicationCommandInteractionDataOption{name: "user", value: user},
        %Nostrum.Struct.ApplicationCommandInteractionDataOption{
          name: "group",
          value: group,
          focused: nil
        }
      ]) do
    Api.create_interaction_response!(
      interaction,
      create_interaction_response(:deferred_channel_message_with_source)
    )

    Vehicles.vehicles(user, group: group)
    |> case do
      {:ok, vehicles} ->
        embeds =
          format_vehicles_embed(vehicles, user)
          |> Enum.map(fn %{title: title} = embed ->
            if String.equivalent?(title, user) do
              Map.put(embed, :title, "#{title} (#{group})")
            else
              embed
            end
          end)

        Api.edit_interaction_response!(
          interaction,
          create_interaction_response_data(embeds: embeds)
        )

      {:error, :not_found} ->
        Api.edit_interaction_response!(
          interaction,
          create_interaction_response_data(content: "Could not find user: `%{user}`", user: user)
        )
    end
  end

  def public(interaction_token, [
        %Nostrum.Struct.ApplicationCommandInteractionDataOption{name: "user", value: user}
      ]) do
    Api.create_interaction_response!(
      interaction_token,
      create_interaction_response(:deferred_channel_message_with_source)
    )

    try do
      embeds =
        Vehicles.vehicles(user)
        |> format_vehicles_embed(user)

      Api.edit_interaction_response!(
        interaction_token,
        create_interaction_response_data(embeds: embeds)
      )
    rescue
      e in Fleetyards.ClientError.NotFound ->
        Api.edit_interaction_response!(
          interaction_token,
          create_interaction_response_data(content: "Could not find user: `%{user}`", user: user)
        )
    end
  end

  def format_vehicles_embed(vehicles, user) do
    loaner_slugs =
      vehicles
      |> Stream.map(fn %{"model" => model} -> Map.get(model, "loaners") end)
      |> Stream.concat()
      |> Stream.map(fn %{"name" => name, "slug" => slug} -> {slug, name} end)
      |> Enum.sort_by(fn {slug, _} -> slug end)
      |> Enum.frequencies()

    ships = format_vehicles(vehicles)

    embeds = public_ships(user, ships)

    loaner_slugs
    |> format_loaners(user)
    |> case do
      nil ->
        [embeds]

      loaners ->
        [embeds, loaners]
    end
  end

  defp public_ships(user, []) do
    %{
      type: "rich",
      title: user,
      description: user <> " has no ships visible in public hangar.",
      color: 0
    }
  end

  defp public_ships(user, ships) do
    %{
      type: "rich",
      title: user,
      description: user <> " has the following ships in hangar:",
      color: 0,
      fields: ships
    }
  end

  defp format_vehicles(vehicles) do
    vehicles =
      vehicles
      |> Enum.sort_by(fn %{"model" => %{"manufacturer" => %{"code" => code}}} -> code end)

    counts =
      vehicles
      |> Enum.frequencies_by(fn %{"name" => name, "model" => %{"slug" => slug}} ->
        slug <> if name, do: "##{name}", else: ""
      end)

    ret =
      vehicles
      |> Enum.dedup_by(fn %{"model" => %{"slug" => slug}} -> slug end)
      |> Enum.chunk_by(fn %{"model" => %{"manufacturer" => %{"code" => code}}} -> code end)
      |> Enum.map(fn [%{"model" => %{"manufacturer" => manufacture}} | _] = models ->
        {manufacture, models}
      end)
      |> Enum.map(&format_manufacturer(&1, counts))
  end

  defp format_manufacturer({%{"name" => name}, vehicles}, counts) do
    vehicles =
      vehicles
      |> Enum.map_join("\n", &format_vehicle(&1, counts))

    %{
      name: name,
      value: vehicles,
      inline: true
    }
  end

  def format_manufacturer({%{"name" => name}, vehicles}) do
    vehicles =
      vehicles
      |> Enum.map_join("\n", &format_vehicle/1)

    %{
      name: name,
      value: vehicles,
      inline: true
    }
  end

  defp format_vehicle(%{"name" => nil, "model" => %{"slug" => slug, "name" => name}}, counts) do
    count = Map.get(counts, slug)

    format_vehicle(name, count)
  end

  defp format_vehicle(%{"name" => name, "model" => %{"slug" => slug, "name" => model_name}}, _) do
    "- #{name} (#{model_name})"
  end

  defp format_vehicle({%{"name" => name}, count}), do: format_vehicle(name, count)

  defp format_vehicle(name, 1) when is_binary(name) do
    "- #{name}"
  end

  defp format_vehicle(name, x) when is_binary(name) and is_integer(x) do
    "- #{name} (#{x}x)"
  end

  defp format_loaners(loaners, user) do
    loaners =
      loaners
      |> Enum.map(fn {{slug, name}, count} ->
        FleetBot.Fleetyards.Models.model(slug)
        |> case do
          {:ok, model} ->
            {model, count}

          _ ->
            nil
        end
      end)
      |> Enum.filter(&(&1 != nil))
      # {FleetBot.Fleetyards.Models.model(slug), count} end)
      |> Enum.sort_by(fn {%{"manufacturer" => %{"code" => code}}, _} -> code end)
      |> Enum.chunk_by(fn {%{"manufacturer" => %{"code" => code}}, _} -> code end)
      |> Enum.map(fn [{%{"manufacturer" => manufacture}, _} | _] = models ->
        {manufacture, models}
      end)
      |> Enum.map(&format_manufacturer/1)
      |> case do
        [] ->
          nil

        ships ->
          %{
            type: "rich",
            title: "Loaners",
            description: user <> " has the following loaners:",
            color: 0,
            fields: ships
          }
      end
  end
end
