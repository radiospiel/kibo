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

def B(*args, &block)
  msg = log_message(*args)
  W msg

  start = Time.now
  yield.tap do
    W "#{msg}: #{(1000 * (Time.now - start)).to_i} msecs."
  end
end

# Success!
def S(*args)
  UI.confirm log_message(*args)
end

def confirm!(msg)
  puts msg
  puts "\n\nPress ^C to abort or return to continue."
  
  STDIN.readline
end
