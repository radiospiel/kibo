require "yaml"

class Kibo::Configfile < Hash
  attr :path
  
  def initialize(path)
    @path = path
    
    File.read(path).
      split("\n").
      each_with_index do |line, lineno|
        next if line =~ /^\s*#/
        die(lineno, "Can't parse line: #{line.inspect}") unless line =~ /\s*([a-z]+):\s*(.*)$/
        key, value = $1, $2.gsub(/\s+$/, "")
        
        die(lineno, "Multiple entries for #{key.inspect}") if key?(key)

        update key => value
      end
  end

  def die(lineno, msg)
    E "#{path}:#{lineno}", msg
  end
end

class Kibo::Config
  attr :procfile

  DEFAULTS = {
    "procfile" => "Procfile"
  }
  
  def [](key)
    @data[key]
  end
  
  def environment
    Kibo.environment
  end
  
  def initialize(path)
    super()

    @data = Hash.new do |hash, key|
      W "#{key}: missing setting for #{environment.inspect} environment, using default."
      hash[key] = DEFAULTS[key]
    end

    begin
      kibo = YAML.load File.read(path)
      @data.update(kibo["defaults"] || {})
      @data.update(kibo[environment] || {})
    rescue Errno::ENOENT
      W "No such file", path
      @data = DEFAULTS
    end
    
    @procfile = Kibo::Configfile.new(self["procfile"])
  end
  
  # processes are defined in the Procfile. The scaling, however, is defined in 
  # the Kibofile.
  def processes
    @processes ||= procfile.keys.inject({}) do |hash, key|
      hash.update key => (self[key] || 1)
    end
  end

  #
  # we need namespace-ENVIRONMENT-process<1>
  
  def kibo
    self["kibo"] || {}
  end
  
  def namespace
    kibo["namespace"] || E("Please set a namespace in your Kibofile.")
  end

  def heroku
    kibo["heroku"] || E("Please set the heroku account email in your Kibofile")
  end

  def remotes_by_process
    remotes = Kibo.git("remote", :quiet).split("\n")
    
    @remotes_by_process ||= remotes.group_by do |remote| 
      case remote
      when /^#{namespace}-#{environment}-(\w+)(\d+)/
        $1
      when /^#{namespace}-#{environment}-/ 
        W "#{remote.inspect}: Ignoring target..."
        nil
      else
      end
    end.tap { |hash| hash.delete(nil) }
  end
end
