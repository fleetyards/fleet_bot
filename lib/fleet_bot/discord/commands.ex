defmodule FleetBot.Discord.Commands do
  use FleetBot.Discord.Commands.Register

  @impl Register
  def global_commands() do
    [
      create_command("login", "Login with fleetyards account",
        member_permission: :SEND_MESSAGES,
        dm_permission: true
      )
    ]
  end
end
