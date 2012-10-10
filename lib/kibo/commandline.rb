require "trollop"

module Kibo::CommandLine
  extend self
  
  def options
    parse; @options
  end

  def subcommand
    parse; @subcommand
  end
  
  def environment
    parse; @environment
  end
  
  def args
    parse; @args
  end
  
  private
  
  COMMANDS_WO_ENVIRONMENT = %w(generate log compress) 
  
  def parse
    return if @options

    commands, descriptions = Kibo::Commands.commands, Kibo::Commands.descriptions
    
    commands = commands.map(&:to_s) & descriptions.keys
    ll_commands, hl_commands = commands.partition { |a| COMMANDS_WO_ENVIRONMENT.include?(a) }
    
    hl_usage = hl_commands.map do |subcommand|
      "  kibo [options] %-33s ... %s" % [ "#{subcommand} <environment>", descriptions[subcommand] ]
    end.compact.join("\n")
    
    ll_usage = ll_commands.map do |subcommand|
      "  kibo [options] %-33s ... %s" % [ subcommand, descriptions[subcommand] ]
    end.compact.join("\n")
    
    @options = Trollop::options do
       version "kibo #{Kibo::VERSION} (c) 2012 radiospiel"
        banner <<-EOS
kibo manages multiple application roles on single heroku dynos.

Usage:

#{hl_usage}

More commands:

#{ll_usage}

where [options] are:
 
EOS

      opt :config, "Set Kibofile name", :short => 'c', :type => String, :default => "Kibofile"

      stop_on Kibo::Commands.commands
    end

    @subcommand = ARGV.shift # get the subcommand

    unless Kibo::Commands.commands.include?(@subcommand)
      if @subcommand
        Trollop.die "Unknown subcommand #{@subcommand.inspect}"
      else 
        Trollop.die "Missing subcommand"
      end
    end

    # Does this subcommand needs the environment setting? 
    # This includes all subcommands except generate and log
    unless COMMANDS_WO_ENVIRONMENT.include?(@subcommands)
      @environment = ARGV.shift || begin
        W "You should supply the <environment> argument. Using default 'staging'"
        "staging"
      end
    end
    
    # Is there a specific subcommand options configuration?

    if proc = Kibo::Commands.options[@subcommand]
      subcommand_options = Trollop::options do
        instance_eval &proc
      end

      @options.update subcommand_options
    end

    @args = ARGV.dup
  end

  def method_missing(sym, *args, &block)
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
end
