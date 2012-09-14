require "bundler/ui"
require "thor/shell"

UI = Bundler::UI::Shell.new(Thor::Shell::Color.new)

def log_message(msg, *args)
  return msg if args.empty?
  "#{msg}: " + args.map(&:inspect).join(", ")
end

def D(*args)
  UI.info log_message(*args)
end

def W(*args)
  UI.warn log_message(*args)
end

def E(*args)
  UI.error log_message(*args)
  exit 1
end

def C(*args)
  UI.confirm log_message(*args)
end
