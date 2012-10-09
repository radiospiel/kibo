require "yaml"
require "mash"

class Kibo::Config < Mash
  DEFAULTS = {
    "heroku"          => {
      "mode" => "freemium"
    },
    "deployment"      => {},
    "collaborations"  => {},
    "source"          => {},
    "collaborators"   => []
  }

  attr :environment, :kibofile
  
  def initialize(kibofile, environment)
    @kibofile, @environment = kibofile, environment
    @kibofile = File.expand_path @kibofile
    
    kibo = begin
      YAML.load File.read(kibofile)
    rescue Errno::ENOENT
      E "No such file", File.expand_path(@kibofile)
    end

    build_config(kibo)
    verify_config
  end
  
  def processes
    return unless processes = super
    processes.reject { |k,v| v.to_s.to_i <= 0 } 
  end

  def freemium?
    heroku.mode == "freemium"
  end
  
  private
  
  def build_config(kibo)
    config = DEFAULTS.dup
    
    [ kibo, kibo["defaults"], kibo[environment] ].each do |hash|
      next unless hash
      config = config.deep_merge(hash)
    end
    
    self.update config
  end
  
  def verify_config
    Kibo::Config.verify_version!(self.version)
    
    # verify required entries
    E("#{@kibofile}: Please set the heroku namespace.") unless heroku.namespace?
    E("#{@kibofile}: Please set the heroku account email") unless heroku.account?
    E("#{@kibofile}: Missing 'processes' settings") unless self.processes.is_a?(Hash)
  end
  
  def self.verify_version!(version)
    return unless version

    kibofile_version = version.split(".").map(&:to_i)
    kibo_version = Kibo::VERSION.split(".").map(&:to_i)

    return if kibo_version >= kibofile_version

    E "The Kibofile requires kibo version #{version}. You have #{Kibo::VERSION}."
  end
end

class Kibo::Instance < String
  attr :count, :role
  
  def initialize(role, count)
    @role, @count = role, count
    super "#{Kibo.namespace}-#{Kibo.environment}-#{role}"
  end

  def addons
    []
  end
  
  class Freemium < self
    def initialize(role, number)
      super role, 1
      @number = number
    
      concat "#{@number}"
    end
  end
end

class Kibo::Config

  # return an array of instances.
  def instances
    instances = if Kibo.config.freemium?
      Kibo.config.processes.map do |process, count|
        1.upto(count).map { |idx| 
          Kibo::Instance::Freemium.new process, idx 
        }
      end.flatten
    else
      Kibo.config.processes.map do |process, count|
        Kibo::Instance.new process, count
      end
    end

    instances.sort_by(&:to_s)
  end
end
