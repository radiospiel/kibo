$:.unshift File.expand_path("../lib", __FILE__)
require "kibo/version"

Gem::Specification.new do |gem|
  gem.name     = "kibo"
  gem.version  = Kibo::VERSION

  gem.author   = "radiospiel"
  gem.email    = "eno@radiospiel.org"
  gem.homepage = "http://github.com/radiospiel/kibo"
  gem.summary  = "Manage heroku instances"

  gem.description = gem.summary

  gem.executables = "kibo"
  gem.files = Dir["**/*"].select { |d| d =~ %r{^(README|bin/|data/|ext/|lib/|spec/|test/)} }
  gem.files << "man/kibo.1"

  gem.add_dependency 'thor', '>= 0.13.6'
end
