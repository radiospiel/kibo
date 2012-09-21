module Kibo::Commands
  subcommand :info, "show information about the current settings"

  def info
    W "Supported commands", Kibo::Commands.commands
    W "whoami", h.whoami
  end
end
