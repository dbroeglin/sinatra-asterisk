SPEC = Gem::Specification.new do |s|

  # Get the facts.
  s.name             = "sinatra-asterisk"
  s.version          = "0.0.1"
  s.description      = "Extension to Sinatra.rb to allow managing an Asterisk IPBX from the web application"

  s.add_dependency "sinatra", "~> 1.0"

  s.add_development_dependency "rspec", ">= 2.0.0"

  s.authors          = ["Dominique BROEGLIN"]
  s.email            = "dominique.broeglin@gmail.com"
  s.files            = Dir["**/*.{rb,md,jar}"] << "LICENSES"
  s.has_rdoc         = 'yard'
  s.homepage         = "http://github.com/dbroeglin/#{s.name}"
  s.require_paths    = ["lib"]
  s.summary          = s.description
  
end
