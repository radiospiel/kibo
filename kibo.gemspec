$:.unshift File.expand_path("../lib", __FILE__)
require "kibo/version"

class Gem::Specification
  class GemfileEvaluator
    def initialize(scope)
      @scope = scope
    end
    
    def load_dependencies(path)
      instance_eval File.read(path) 
    end
    
    def source(*args); end
    def group(*args); end

    def gem(name, *requirements)
      @scope.add_dependency(name, *requirements)
    end
  end
  
  def load_dependencies(file)
    GemfileEvaluator.new(self).load_dependencies(file)
  end
end

Gem::Specification.new do |gem|
  gem.name     = "kibo"
  gem.version  = Kibo::VERSION

  gem.authors   = ["radiospiel"]
  gem.email     = ["eno@radiospiel.org"]
  gem.homepage  = "http://github.com/radiospiel/kibo"
  gem.summary   = "Manage heroku instances with ease"

  gem.description = gem.summary

  gem.load_dependencies "Gemfile"
  
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
