# defmodule FleetBot.Fleetyards.Session do
#  use FleetBot.Fleetyards
#
#  def login(username, password) do
#    body =
#      %{
#        "login" => username,
#        "password" => password,
#        "remember_me" => true
#      }
#
#    with {:ok, %HTTPoison.Response{status_code: 200, body: %{"token" => token} = body}} <-
#           @backend.post("/v1/sessions", body, [{"Content-Type", "application/json"}]) do
#    else
#      {:ok,
#       %HTTPoison.Response{
#         status_code: 400,
#         body: %{"code" => "session.create.not_found_in_database"}
#       } = resp} ->
#        IO.inspect(resp)
#        {:error, :invalid_username_password}
#
#      v ->
#    end
#  end
#
#  def logout(token) do
#    with {:ok, %HTTPoison.Response{status_code: 200, body: %{"code" => "sessions.destroy"}}} <-
#           @backend.delete("/v1/sessions", [get_auth_header(token)]) do
#      :ok
#    else
#      v -> v
#    end
#  end
# end
