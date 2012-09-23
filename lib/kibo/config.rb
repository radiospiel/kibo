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
  rescue
    E "No such file", path
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

    @data = DEFAULTS.dup
    
    begin
      kibo = YAML.load File.read(path)
      @data.update(kibo)
      @data.update(kibo["defaults"] || {})
      @data.update(kibo[environment] || {})
    rescue Errno::ENOENT
      W "No such file", path
    end
    
    verify_version!
    
    @procfile = Kibo::Configfile.new(self["procfile"])
  end
  
  # processes are defined in the Procfile. The scaling, however, is defined in 
  # the Kibofile.
  def processes
    @processes ||= procfile.keys.inject({}) do |hash, key|
      hash.update key => (self[key] || 1)
    end
  end

  def verify_version!
    return unless self["version"]

    files_version = self["version"].split(".").map(&:to_i)
    kibos_version = Kibo::VERSION.split(".").map(&:to_i)

    files_version.zip(kibos_version).each do |files, kibos|
      next if kibos == files
      if kibos > files
        W "The Kibofile requires kibo version #{self["version"]}. You have #{Kibo::VERSION}... this might work."
        return
      end
      
      E "The Kibofile requires kibo version #{self["version"]}. You have #{Kibo::VERSION}."
    end
  end

  #
  # we need namespace-ENVIRONMENT-process<1>
  
  # returns the heroku configuration
  def heroku
    self["heroku"] || {}
  end
  
  # returns deployment specific configuration
  def deployment
    self["deployment"] || {}
  end

  # returns source specific configuration
  def source
    self["source"] || {}
  end
  
  # returns the heroku namespace
  def namespace
    heroku["namespace"] || E("Please set the heroku namespace in your Kibofile.")
  end

  # returns the heroku account email. This is the account that
  # you should be logged in
  def account
    heroku["account"] || E("Please set the heroku account email in your Kibofile")
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
