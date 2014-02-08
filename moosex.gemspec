# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'moosex/version'

Gem::Specification.new do |spec|	
  spec.name          = "moosex"
  spec.version       = MooseX::VERSION
  spec.authors       = ["Tiago Peczenyj"]
  spec.email         = ["tiago.peczenyj@gmail.com"]
  spec.summary       = %q{A postmodern object DSL for Ruby}
  spec.description   = %q{MooseX is an extension of Ruby object DSL. The main goal of MooseX is to make Ruby Object Oriented programming easier, more consistent, and less tedious. With MooseX you can think more about what you want to do and less about the mechanics of OOP. It is a port of Moose/Moo from Perl to Ruby world.}
  spec.homepage      = "http://github.com/peczenyj/MooseX"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.0'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov", ">= 0.8.2"
  spec.add_development_dependency 'coveralls', '>= 0.7.0'
end
