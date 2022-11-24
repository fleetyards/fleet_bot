defmodule FleetBot.Fleetyards.ModelsTest do
  use FleetBot.ExUnitCase
  # doctest FleetBot.Fleetyards.Models, import: true
  alias FleetBot.Fleetyards.Models

  setup do
    FleetBot.Fleetyards.Cache.flush()
    :ok
  end

  describe "slugs" do
    test "ok" do
      models = ~w(msr 600i-touring)
      # fn _ -> {:ok, %HTTPoison.Response{status_code: 200, body: models}} end)
      expect(FleetBot.Fleetyards.ClientMock, :get, create_response_func(models))

      assert Models.slugs() == models
    end

    test "error" do
      expect(
        FleetBot.Fleetyards.ClientMock,
        :get,
        create_response_func(400, %{"code" => "error"})
      )

      assert Models.slugs() == []
    end

    test "search" do
      models = ~w(msr 600i-touring)
      # fn _ -> {:ok, %HTTPoison.Response{status_code: 200, body: models}} end)
      expect(FleetBot.Fleetyards.ClientMock, :get, create_response_func(models))

      assert Models.search_slug("60") == ["600i-touring"]
    end

    test "search discord" do
      models = ~w(msr 600i-touring)
      # fn _ -> {:ok, %HTTPoison.Response{status_code: 200, body: models}} end)
      expect(FleetBot.Fleetyards.ClientMock, :get, create_response_func(models))

      expect(FleetBot.Fleetyards.ClientMock, :get, fn _ ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: %{"name" => "600i Touring", "slug" => "600i-touring"}
         }}
      end)

      [touring] = Models.get_discord_slug_choices("60")
      assert Map.get(touring, :name) == "600i Touring"
      assert Map.get(touring, :value) == "600i-touring"
    end
  end
end
