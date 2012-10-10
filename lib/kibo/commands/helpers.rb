require "forwardable"
require_relative "../system"


module Kibo::Commands

  private 
  
  extend Forwardable
  
  delegate [:git, :git?, :heroku, :sys] => Kibo::System

  # -- which remotes are defined, present and configured --------------

end
