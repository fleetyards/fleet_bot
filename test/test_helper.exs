ExUnit.start()

defmodule FleetBot.ExUnitCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      def create_response(status \\ 200, body) do
        %HTTPoison.Response{status_code: status, body: body}
      end

      defmacro create_response_func(status \\ 200, body) do
        quote do
          fn _ -> {:ok, create_response(unquote(status), unquote(body))} end
        end
      end

      import Mox

      setup :verify_on_exit!
    end
  end
end

Application.ensure_started(:nebulex)
# Start the Ecto repository so we can use it in tests.
{:ok, _pid} =
  Supervisor.start_link(
    [
      FleetBot.Repo,
      FleetBot.Fleetyards.Supervisor,
      Mox.Server
    ],
    strategy: :one_for_one
  )

Mox.defmock(FleetBot.Fleetyards.ClientMock, for: HTTPoison.Base)
