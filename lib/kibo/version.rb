module Kibo
  VERSION = "0.4.8"
  # Note: Keep the '"' string characters here!
end

if $0 == __FILE__

  def next_version
    parts = Kibo::VERSION.split(".")
    parts[parts.length - 1] = parts[parts.length - 1].to_i + 1
    parts.join(".")
  end

  rex = Regexp.new("VERSION.*" + Regexp.escape(Kibo::VERSION.inspect))

  lines = File.readlines(__FILE__).map do |line|
    next line unless line =~ rex
    "  VERSION = #{next_version.inspect}\n"
  end
  
  puts lines.join

end
