require_relative 'test_helper'


module Kibo::CommandLine
  extend self
  
  def parse
    raise "CommandLine::parse"
  end
end

class KiboTest < Test::Unit::TestCase
  def config(environment = "staging")
    Kibo::Config.new(File.dirname(__FILE__) + "/Kibofile", environment)
  end
  
  def test_missing_config
    assert_raise(FatalError) {  
      Kibo::Config.new(File.dirname(__FILE__) + "/Kibofile.missing", "environment")
    }
  end

  def test_verify_version
    assert(Kibo::VERSION =~ /^0\.4/)
    
    assert_raise(FatalError) {  
      Kibo::Config.verify_version!("1.0")
    }

    assert_raise(FatalError) {  
      Kibo::Config.verify_version!("0.5")
    }

    assert_nothing_raised(FatalError) {  
      Kibo::Config.verify_version!(Kibo::VERSION)
      Kibo::Config.verify_version!("0.1")
    }
  end
  
  def test_config
    config = self.config
    
    assert_equal({"clerk"=>1, "twirl"=>1}, config.processes)
    
    assert_equal config.namespace, "kibo"
    assert config.freemium?
    assert_equal ["kibo-staging-clerk1", "kibo-staging-twirl1"], config.instances
  end

  def test_live_config
    config = self.config("live")

    assert_equal({"clerk"=>1, "twirl"=>3}, config.processes)
    
    assert_equal config.namespace, "kibo"
    assert !config.freemium?
    assert_equal ["kibo-live-clerk", "kibo-live-twirl"], config.instances
  end
end
