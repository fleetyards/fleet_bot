defmodule FleetBot.Fleetyards.Vehicles do
  alias FleetBot.Fleetyards
  use FleetBot.Fleetyards
  use Nebulex.Caching
  # use Nebulex.Caching

  # @task_sup FleetBot.Fleetyards.TaskSupervisor
  @doc """
  Get all public vehicles by username
  """
  def vehicles(username, opts \\ []) when is_binary(username) do
    query =
      []
      |> add_query(opts, :per_page, "perPgae", "all")
      |> add_query(opts, :group, "q[hangarGroupsIn][]")

    @backend.get("/v1/vehicles/" <> username <> "?" <> URI.encode_query(query))
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} when is_list(body) ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 404, body: %{"code" => "not_found"}}} ->
        {:error, :not_found}
    end
  end

  @decorate cacheable(
              cache: FleetBot.Fleetyards.Cache,
              key: {__MODULE__, :groups, username},
              match: &Fleetyards.Cache.match_non_error/1,
              opts: [ttl: :timer.minutes(5)]
            )
  def groups(username) when is_binary(username) do
    @backend.get("/v1/hangar-groups/" <> username)
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 404, body: %{"code" => "not_found"}}} ->
        {:error, :not_found}
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

  defp add_query(query, opts, key, name, default \\ nil) do
    value = Keyword.get(opts, key, default)

    if value != nil do
      [{name, value} | query]
    else
      query
    end
  end
end
