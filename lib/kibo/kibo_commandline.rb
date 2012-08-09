require "trollop"

module Kibo::CommandLine
  def self.method_missing(sym, *args, &block)
    if block_given? || !args.empty?
      super
    elsif options.key?(sym)
      options[sym]
    elsif (sym.to_s =~ /(.*)\?/) && options.key?($1.to_sym)
      !! options[$1.to_sym]
    else
      super
    end 
  end
  
  def self.options
    parse unless @options
    @options
  end

  def self.subcommand
    parse unless @options
    @subcommand
  end
  
  def self.parse_and_get(name)
    parse unless @options
    instance_variable_get "@#{name}"
  end
  
  SUBCOMMANDS = %w(create deploy spinup spindown reconfigure)
  
  def self.parse
    @options = Trollop::options do
       version "test 1.2.3 (c) 2008 William Morgan"
        banner <<-EOS
kibo is an awesome program that does something very, very important.

Usage:

  kibo [options] create                     ... create missing targets
  kibo [options] deploy                     ... updates all remote instances
  kibo [options] spinup                     ... starts all remote instances
  kibo [options] spindown                   ... stops all remote instances
  kibo [options] reconfigure                ... reconfigure all existing targets

where [options] are:
 
EOS

      opt :environment, "Set environment", :short => 'e', :type => String, :default => "staging"
      opt :kibofile, "Set Kibofile name", :short => 'k', :type => String, :default => "Kibofile"
      opt :procfile, "Set Procfile name", :short => 'p', :type => String, :default => "Procfile"
      opt :dry_run, "Do nothing", :short => 'n'

      stop_on SUBCOMMANDS
    end

    @subcommand = ARGV.shift # get the subcommand

    unless SUBCOMMANDS.include?(@subcommand)
      Trollop::die(@subcommand ? "Unknown subcommand #{@subcommand.inspect}" : "Missing subcommand")
    end

    # Is there a specific subcommand options configuration?
     
    subcommand_options = 
      case @subcommand
      when "spinup" # parse delete options
        Trollop::options do
          opt :force, "Ignore missing targets.", :short => "f"
        end
      end
    
    @options.update subcommand_options if subcommand_options
  end

end
