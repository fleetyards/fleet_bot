defmodule FleetBot.Fleetyards.Models do
  alias FleetBot.Fleetyards
  use FleetBot.Fleetyards
  use Nebulex.Caching

  @ttl :timer.hours(1)
  @task_sup FleetBot.Fleetyards.TaskSupervisor

  @typedoc """
  Fleetyards model.
  """
  @type t() :: %{
          name: String.t(),
          slug: Fleetyards.slug()
        }

  @doc """
  Get a List of all current Model slugs

  ## Example

      iex> slugs()
      ["msr", "600i-touring"]
  """
  @spec slugs() :: [Fleetyards.slug()]
  @decorate cacheable(
              cache: FleetBot.Fleetyards.Cache,
              key: {__MODULE__, :slugs},
              match: &Fleetyards.Cache.match_non_error/1,
              opts: [ttl: @ttl]
            )
  # TODO: cache
  def slugs() do
    # @backend.get("/v1/models/slugs")
    # |> case do
    #  {:ok, %HTTPoison.Response{status_code: 200, body: body}} when is_list(body) ->
    #    body

    #  _ ->
    #    []
    # end
  end

  @doc """
  Get Fleetyards model by slug.
  """
  @spec model(Fleetyards.slug()) :: {:ok, __MODULE__.t()} | {:error, term()}
  @decorate cacheable(
              cache: FleetBot.Fleetyards.Cache,
              key: {__MODULE__, slug},
              match: &Fleetyards.Cache.match_non_error/1,
              opts: [ttl: @ttl]
            )
  def model(slug) when is_binary(slug) do
    # @backend.get("/v1/models/" <> slug)
    # |> case do
    #  {:ok, %HTTPoison.Response{status_code: 200, body: body}} when is_map(body) ->
    #    {:ok, body}

    #  {:ok, %HTTPoison.Response{status_code: 404, body: %{"code" => "not_found"}}} ->
    #    {:error, :not_found}

    #  v ->
    #    v
    # end
  end

  ## Helpers
  @doc """
  Search Fleetyards for slug.

  ## Example

    iex> search_slug("touring")
    ["600i-touring"]
  """
  @spec search_slug(String.t(), integer()) :: [Fleetyards.slug()]
  def search_slug(search, num \\ nil) do
    stream =
      slugs()
      |> Stream.filter(&String.contains?(&1, search))

    if num != nil do
      stream
      |> Enum.take(num)
    else
      stream
    end
    |> Enum.into([])
  end

  @doc """
  Search Fleetyards for slug, and return discord autocompletion result.

  ## Example

    iex> get_discord_slug_choices("touring")
    [%{name: "600i Touring", value: "600i-touring"}]
  """
  @spec get_discord_slug_choices(String.t(), integer(), integer()) :: [
          %{value: Fleetyards.slug(), name: String.t()}
        ]
  def get_discord_slug_choices(search, num \\ 25, timeout \\ 1_000) do
    slugs = search_slug(search, num)

    named_slugs =
      slugs
      |> Enum.map(&Task.Supervisor.async_nolink(@task_sup, __MODULE__, :model, [&1]))
      |> Task.yield_many(timeout)
      |> Enum.filter(fn
        {_, {:ok, _}} -> true
        _ -> false
      end)
      |> Enum.map(fn {_, {:ok, {:ok, model}}} ->
        {Map.get(model, "slug"), Map.get(model, "name")}
      end)

    slugs
    |> Enum.filter(fn slug ->
      Enum.find_index(named_slugs, fn
        {^slug, _} -> true
        _ -> false
      end) == nil
    end)
    |> Enum.map(&{&1, &1})
    |> Enum.concat(named_slugs)
    |> Enum.map(fn {value, name} -> %{value: value, name: name} end)
  end
end
