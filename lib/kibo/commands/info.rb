module Kibo::Commands
  subcommand :info, "show information about the current settings"

  def info
    Info.print do |info|
      info.head "general"
      info.line "environment", Kibo.environment

      info.head "heroku"
      info.line "current account", h.whoami
      info.line "expected account", Kibo.config.account

      info.head "remotes"
      info.line "remotes", h.expected_remotes
      info.line "configured", h.configured_remotes
      info.line "missing", h.missing_remotes
    end
  end

  class Info < Array
    def self.print(out = STDOUT, &block)
      out.puts build(&block).to_s
    end
    
    def self.build(&block)
      info = Info.new
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
      fmt = key_format
      
      map do |kind, msg, value|
        case kind
        when :head
          "== #{msg} " + "=" * (100 - msg.length)
        when :line
          msg = fmt % msg
          
          case value
          when [], nil then "#{msg}: <none>"
          when Array   then "#{msg}: " + value.map(&:inspect).join(", ")
          else              "#{msg}: #{value}"
          end
        end
      end.join("\n")
    end
    
    private
    
    def key_format
      max_key_length = map do |kind, msg, value| 
        kind == :line ? msg.length : 0
      end.max

      fmt = "%#{max_key_length + 4}s"
    end
  end
end
