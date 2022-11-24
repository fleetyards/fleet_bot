defmodule FleetBot.Fleetyards.Models do
  use FleetBot.Fleetyards

  @doc """
  Get a List of all current Model slugs

  ## Example

      iex> slugs()
      ["msr", "600i-touring"]
  """
  @spec slugs() :: [String.t()]
  # TODO: cache
  def slugs() do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} when is_list(body) <-
           @backend.get("/v1/models/slugs") do
      body
    else
      _ ->
        []
    end
  end

  def model(slug) when is_binary(slug) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} when is_map(body) <-
           @backend.get("/v1/models/" <> slug) do
      {:ok, body}
    else
      {:ok, %HTTPoison.Response{status_code: 404, body: %{"code" => "not_found"}}} ->
        {:error, :not_found}

      v ->
        v
    end
  end

  ## Helpers
  def search_slug(search, num \\ nil) do
    stream =
      slugs()
      |> Stream.filter(&String.contains?(&1, search))

    if num != nil do
      stream
      |> Enum.take(25)
    else
      stream
    end
    |> Enum.into([])
  end

  def get_discord_slug_choices(search, num \\ 25) do
    # TODO: get actuall name instead of slug
    search_slug(search, num)
    |> Stream.map(fn slug -> %{name: slug, value: slug} end)
    |> Enum.into([])
  end
end
