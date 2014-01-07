# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require 'authy/version'

Gem::Specification.new do |s|
  s.name        = "authy"
  s.version     = Authy::VERSION
  s.authors     = ["Authy Inc"]
  s.email       = ["support@authy.com"]
  s.homepage    = "https://github.com/authy/authy-ruby"
  s.summary     = %q{Ruby library to access Authy services}
  s.description = %q{Ruby library to access Authy services}
  s.license = 'MIT'

  s.rubyforge_project = "authy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('httpclient', '>= 2.3.4')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('pry')
  s.add_development_dependency('yard')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('reek')
end
