defmodule FleetBot.Fleetyards.Tesla.DecodeFleetyardsPagination do
  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, _opts) do
    env
    |> Tesla.run(next)
    |> case do
      {:ok, env} -> Tesla.run(env, [{Tesla.Middleware.DecodeRels, :call, [[], nil]}])
      v -> v
    end
    |> parse_page
  end

  defp parse_page({:ok, env}), do: {:ok, parse_pages(env)}
  defp parse_page({:error, _} = e), do: e

  defp parse_pages(%Tesla.Env{opts: opts} = env) do
    if rels = Keyword.get(opts, :rels) do
      links =
        rels
        |> Enum.map(&parse_page_link/1)
        |> Enum.filter(&(&1 != nil))
        |> Enum.into(%{})

      Tesla.put_opt(env, :fleetyards, links)
    else
      env
    end
  end

  defp parse_page_link({key, link}) do
    URI.parse(link).query
    |> case do
      nil ->
        nil

      query ->
        query =
          URI.decode_query(query)
          |> Enum.map(&parse_data/1)
          |> Enum.into(%{})

        {key, query}
    end
  end

  defp parse_data({n, v}) when is_binary(v) do
    try do
      v = String.to_integer(v)
      {n, v}
    rescue
      _ ->
        {n, v}
    end
  end
end
