# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sinatra/asterisk/version"

Gem::Specification.new do |s|
  s.name        = "sinatra-asterisk"
  s.version     = Sinatra::Asterisk::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dominique BROEGLIN"]
  s.email       = ["dominique.broeglin@gmail.com"]
  s.homepage    = "https://github.com/dbroeglin/sinatra-asterisk"
  s.summary     = %q{IPBX applications extension for Sinatra.rb}
  s.description = %q{Extension to Sinatra.rb to allow managing an Asterisk IPBX from the web application}

  s.rubyforge_project = "sinatra-asterisk"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.has_rdoc      = 'yard'

  s.add_dependency "sinatra", "~> 1.0"

  s.add_development_dependency "rspec", ">= 2.0.0"
  s.add_development_dependency "gem-release"
end
