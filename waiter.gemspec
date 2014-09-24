# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'waiter/version'

Gem::Specification.new do |gem|
  gem.name          = "waiter"
  gem.version       = Waiter::VERSION
  gem.authors       = ["Daniel Vandersluis"]
  gem.email         = ["dvandersluis@selfmgmt.com"]
  gem.description   = "Provides an easy DSL for serving up menus"
  gem.summary       = "Quick and easy DSL for generating menus for use in Rails applications"
  gem.homepage      = "https://github.com/dvandersluis/waiter"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "activesupport", "> 3.0.0"
  gem.add_dependency "haml"
  gem.add_development_dependency "rspec", ">= 3.1.0"
  gem.add_development_dependency "rspec-its"
  gem.add_development_dependency "rake"
end
