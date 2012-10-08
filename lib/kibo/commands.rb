module Kibo::Commands
  extend self

  def self.options
    @options ||= {}
  end
  
  def self.descriptions
    @descriptions ||= {}
  end
  
  def self.subcommand(name, description = nil, &block)
    options[name.to_s] = Proc.new if block_given?
    descriptions[name.to_s] = description
  end
  
  def self.commands
    public_instance_methods.map(&:to_s)
  end
end

subfiles = Dir.glob( __FILE__.gsub(/\.rb$/, "/*.rb")).sort
subfiles.each { |file| load file }
