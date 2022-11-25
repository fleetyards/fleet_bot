defmodule FleetBot.Discord.Hangar do
  alias JasonVendored.Encode
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
          token: interaction_token,
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
    Api.create_interaction_response!(
      interaction,
      create_interaction_response(:deferred_channel_message_with_source)
    )

    Task.Supervisor.async_nolink(@task_sup, __MODULE__, :public, [interaction_token, args])
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
              )
            ]
          )
        ]
      )
    ]
  end

  # Internal functions
  def public(interaction_token, [
        %Nostrum.Struct.ApplicationCommandInteractionDataOption{name: "user", value: user}
      ]) do
    Vehicles.vehicles(user)
    |> case do
      {:ok, vehicles} ->
        loaner_slugs =
          vehicles
          |> Enum.map(fn %{"model" => model} -> Map.get(model, "loaners") end)
          |> Enum.concat()
          |> Enum.map(fn %{"name" => name, "slug" => slug} -> {slug, name} end)
          |> Enum.sort_by(fn {slug, _} -> slug end)
          |> Enum.frequencies()
          |> Enum.into([])

        ships = format_vehicles(vehicles)

        embeds = public_ships(user, ships)

        embeds =
          loaner_slugs
          |> format_loaners(user)
          |> case do
            nil ->
              [embeds]

            loaners ->
              [embeds, loaners]
          end

        Api.edit_interaction_response!(
          interaction_token,
          create_interaction_response_data(embeds: embeds)
        )

      {:error, :not_found} ->
        Api.edit_interaction_response!(
          interaction_token,
          create_interaction_response_data(content: "Could not find user: `%{user}`", user: user)
        )
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
      |> Enum.map(&format_vehicle(&1, counts))
      |> Enum.join("\n")

    %{
      name: name,
      value: vehicles,
      inline: false
    }
  end

  def format_manufacturer({%{"name" => name}, vehicles}) do
    vehicles =
      vehicles
      |> Enum.map(&format_vehicle/1)
      |> Enum.join("\n")

    %{
      name: name,
      value: vehicles,
      inline: false
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
        end
      end)
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
