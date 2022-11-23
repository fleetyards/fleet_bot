defmodule FleetBot.Repo.Discord.FleetyardsAccount do
  alias FleetBot.Discord
  use Ecto.Schema
  import Ecto.Changeset

  alias FleetBot.Repo

  @type t() :: %__MODULE__{
          user_id: Nostrum.Snowflake.t(),
          fleetyards_token: String.t()
        }

  schema "fleetyards_accounts" do
    field :user_id, :integer
    field :fleetyards_token, :string, redact: true
  end

  ## Api
  def add_aoount(%Nostrum.Struct.User{id: user_id}, token), do: add_account(user_id, token)

  def add_account(user_id, token) when is_integer(user_id) and is_binary(token) do
    create_changeset(%{user_id: user_id, fleetyards_token: token})
    |> Repo.insert()
  end

  def get_account(%Nostrum.Struct.User{id: user_id}), do: get_account(user_id)

  def get_account(user_id) when is_integer(user_id) do
    Repo.get_by(__MODULE__, user_id: user_id)
  end

  ## Changeset
  def create_changeset(account \\ %__MODULE__{}, attrs) do
    account
    |> cast(attrs, [:user_id, :fleetyards_token])
    |> Discord.validate_snowflake(:user_id)
    |> unique_constraint(:user_id)
    |> unique_constraint(:fleetyards_token)
    |> validate_required([:user_id, :fleetyards_token])
  end
end
