defmodule FleetBot.Fleetyards.Vehicles do
  alias FleetBot.Fleetyards
  use FleetBot.Fleetyards
  use Nebulex.Caching

  # @task_sup FleetBot.Fleetyards.TaskSupervisor
  @doc """
  Get all public vehicles by username
  """
  def vehicles_one(username, query \\ []) when is_binary(username) do
    Client.get("/v1/vehicles/#{username}", query: query)
    |> match_error
    |> case do
      {:ok, %Tesla.Env{body: body, opts: opts}} ->
        {:ok, body, opts}

      e ->
        e
    end
  end

  def vehicles_stream(username, page \\ 1, query \\ %{}) do
    Stream.resource(
      fn ->
        page
      end,
      fn
        x when is_number(x) ->
          case vehicles_one(username, Map.put(query, "page", x)) do
            {:ok, elem, opts} ->
              fleetyards = Keyword.get(opts, :fleetyards, %{})

              last = Map.get(fleetyards, "last", %{"page" => x})

              if Map.get(last, "page") >= x do
                {elem, x + 1}
              else
                {elem, :end}
              end

            # Retry
            # TODO: don't try indefinetly?
            {:error, :timeout} ->
              {[], x}

            {:error, :not_found} ->
              raise FleetBot.Fleetyards.ClientError.NotFound, message: "User not found"

            v ->
              {:halt, v}
          end

        :end ->
          {:halt, :end}
      end,
      fn _ -> nil end
    )
  end

  @deprecated "use vehicles_stream/3"
  def vehicles(username, page \\ 1, query \\ %{}) when is_binary(username) do
    vehicles_stream(username, page, query)
    |> Enum.into([])
  end

  @doc """
  Get public groups of user

  ## Examples

    iex> groups("no_groups")
    {:ok, []}

    iex> {:ok, groups} = groups("groups")
    ...> Enum.count(groups)
    2
  """
  @decorate cacheable(
              cache: FleetBot.Fleetyards.Cache,
              key: {__MODULE__, :groups, username},
              match: &Fleetyards.Cache.match_non_error/1,
              opts: [ttl: :timer.minutes(5)]
            )
  def groups(username) when is_binary(username) do
    Client.get("/v1/hangar-groups/#{username}")
    |> match_error
    |> case do
      {:ok, %Tesla.Env{body: body}} -> {:ok, body}
      e -> e
    end
  end

  ## Helpers
  def search_group(username, search, num \\ nil) do
    stream =
      groups(username)
      |> case do
        {:ok, groups} -> groups
        _ -> []
      end
      |> Stream.filter(fn %{"name" => name, "slug" => slug} ->
        String.contains?(name, search) or String.contains?(slug, search)
      end)

    if num != nil do
      stream
      |> Enum.take(num)
    else
      stream
    end
    |> Enum.into([])
  end

  def get_discord_group_choices(username, search, num \\ 25, timeout \\ 1_000) do
    groups = search_group(username, search, num)

    groups
    |> Enum.map(fn %{"name" => name, "slug" => slug} ->
      %{
        value: slug,
        name: name
      }
    end)
  end
end
