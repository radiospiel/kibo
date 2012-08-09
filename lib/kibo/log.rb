def log_message(msg, *args)
  return msg if args.empty?
  "#{msg}: " + args.map(&:inspect).join(", ")
end

def D(*args)
  STDERR.puts log_message(*args)
end

def W(*args)
  STDERR.puts log_message(*args)
end

def E(*args)
  STDERR.puts log_message(*args)
  exit 1
end

