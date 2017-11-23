
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lieutenant/version'

Gem::Specification.new do |spec|
  spec.name          = 'lieutenant'
  spec.version       = Lieutenant::VERSION
  spec.authors       = ['Gabriel Teles']
  spec.email         = ['gab.teles@hotmail.com']

  spec.summary       = 'CQRS/ES Framework to command them all'
  spec.homepage      = 'https://github.com/gabteles/lieutenant'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'yard'
  spec.add_dependency 'activemodel'
end
