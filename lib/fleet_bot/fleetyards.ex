defmodule FleetBot.Fleetyards do
  alias FleetBot.Fleetyards.Client

  @typedoc """
  Fleetyards model slug.
  """
  @type slug() :: String.t()

  @type error() :: {:error, :not_found} | {:error, String.t()}

  @doc """
  Get Fleetyards api version

  ## Examples
    iex> version()
    {:ok, {"v5.11.4", "Odyssey"}}
  """
  @spec version() :: {:ok, {String.t(), String.t()}} :: error()
  def version do
    Client.get("/v1/version")
    |> match_error()
    |> case do
      {:ok, %Tesla.Env{body: %{"codename" => codename, "version" => version}}} ->
        {:ok, {version, codename}}

      v ->
        v
    end
  end

  @doc false
  def match_error({:ok, %Tesla.Env{status: 404, body: %{"code" => "not_found"}}}),
    do: {:error, :not_found}

  def match_error({:error, "timeout"}), do: {:error, :timeout}
  def match_error(v), do: v

  @doc false
  def unpack_body({:ok, %Tesla.Env{status: 200, body: body}}), do: {:ok, body}
  def unpack_body(v), do: match_error(v)

  defmacro __using__(_opts) do
    quote do
      alias unquote(__MODULE__)
      alias FleetBot.Fleetyards.Client
      import unquote(__MODULE__), only: [match_error: 1, unpack_body: 1]
    end
  end
end
