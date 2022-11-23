defmodule FleetBot.Repo.Migrations.FleetyardsAccounts do
  use Ecto.Migration

  def change do
    create table(:fleetyards_accounts) do
      add :user_id, :bigint, null: false
      add :fleetyards_token, :string, null: false
    end

    create unique_index(:fleetyards_accounts, [:user_id])
  end
end
