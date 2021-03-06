# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cellulon/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Tony Arcieri"]
  gem.email         = ["tony.arcieri@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "cellulon"
  gem.require_paths = ["lib"]
  gem.version       = Cellulon::VERSION
 
  gem.add_runtime_dependency 'celluloid'
  gem.add_runtime_dependency 'cinch'
  gem.add_runtime_dependency 'tinder'
end
