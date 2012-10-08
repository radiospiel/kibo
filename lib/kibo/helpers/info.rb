module Kibo::Helpers; end

class Kibo::Helpers::Info < Array
  def self.print(out = STDOUT, &block)
    out.puts build(&block).to_s
  end
  
  def self.build(&block)
    info = new
    yield info
    info
  end
  
  def head(msg)
    push [ :head, msg ]
  end
  
  def line(msg, value)
    push [ :line, msg, value ]
  end
  
  def to_s
    key_length = map do |kind, msg, value| 
      kind == :line ? msg.length : 0
    end.max

    key_length = 60 if key_length > 60
    
    key_format = "%#{key_length + 4}s"
    
    map do |kind, msg, value|
      case kind
      when :head
        "== #{msg} " + "=" * (100 - msg.length)
      when :line
        case value
        when [], nil then value = "<none>"
        when Array   then value = value.map(&:inspect).join(", ")
        end

        if msg == ""
          "#{key_format % msg}  #{value}"
        elsif msg.length > key_length
          msg = msg[0..20] + "..." + msg[(25 - key_length) ..-1]
          "#{key_format % msg}: #{value}"
        else
          "#{key_format % msg}: #{value}"
        end
      end
    end.join("\n")
  end
end
