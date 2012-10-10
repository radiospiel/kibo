require "forwardable"
require_relative "../system"


module Kibo::Commands

  private 
  
  extend Forwardable
  
  delegate [:git, :git?, :sys] => Kibo::System

  def heroku!(*args)
    Kibo::System.heroku *args
  end
end
