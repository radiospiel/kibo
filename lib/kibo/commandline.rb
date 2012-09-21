require "trollop"
require "kibo/version"

module Kibo::CommandLine
  extend self
  
  def options
    parse; @options
  end

  def subcommand
    parse; @subcommand
  end

  def args
    parse; @args
  end
  
  private
  
  def parse
    return if @options

    usage = Kibo::Commands.commands.map do |subcommand|
      next unless description = Kibo::Commands.descriptions[subcommand.to_s]
      "  kibo [options] %-30s ... %s" % [ subcommand, description ]
    end.compact.join("\n")
    
    @options = Trollop::options do
       version "kibo #{Kibo::VERSION} (c) 2012 radiospiel"
        banner <<-EOS
kibo manages multiple application roles on single heroku dynos.

Usage:

#{usage}

where [options] are:
 
EOS

      opt :environment, "Set environment", :short => 'e', :type => String, :default => "staging"
      opt :kibofile, "Set Kibofile name", :short => 'k', :type => String, :default => "Kibofile"
      opt :procfile, "Set Procfile name", :short => 'p', :type => String, :default => "Procfile"

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
