# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'timespan/version'

Gem::Specification.new do |spec|
  spec.name          = "timespan"
  spec.version       = Timespan::VERSION
  spec.authors       = ["Kristian Mandrup"]
  spec.date          = "2013-03-13"
  spec.summary       = "Calculate and store time distance (Mongoid only)"
  spec.description   = "Makes it easy to store time duration, make calculations and comparions and store the duration using Mongoid"
  spec.email         = "kmandrup@gmail.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'chronic'
  spec.add_dependency 'chronic_duration'
  spec.add_dependency 'activesupport',          '>= 3.0'
  spec.add_dependency 'spanner'
  spec.add_dependency 'sugar-high',             '>= 0.7.3'
  spec.add_dependency 'xduration',              '>= 3.0.0'
  spec.add_dependency 'origin-selectable_ext'

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec",    ">= 2.12.0"
  spec.add_development_dependency 'rails',    '>= 3.1'

  # Mongoid specific
  spec.add_development_dependency 'mongoid',               '>= 3.0'
  spec.add_development_dependency 'origin-selectable_ext', '~> 0.1.1'
end
