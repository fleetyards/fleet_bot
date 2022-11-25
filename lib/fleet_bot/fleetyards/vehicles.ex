defmodule FleetBot.Fleetyards.Vehicles do
  alias FleetBot.Fleetyards
  use FleetBot.Fleetyards
  # use Nebulex.Caching

  # @task_sup FleetBot.Fleetyards.TaskSupervisor
  @doc """
  Get all public vehicles by username
  """
  def vehicles(username) when is_binary(username) do
    @backend.get("/v1/vehicles/" <> username <> "?perPage=all")
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} when is_list(body) ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 404, body: %{"code" => "not_found"}}} ->
        {:error, :not_found}
    end
  end
end
