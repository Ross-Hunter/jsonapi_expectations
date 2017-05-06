# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jsonapi_expectations/version'

Gem::Specification.new do |spec|
  spec.name          = "jsonapi_expectations"
  spec.version       = JsonapiExpectations::VERSION
  spec.authors       = ["Ross-Hunter"]
  spec.email         = ["ross-hunter@ross-hunter.com"]

  spec.summary       = %q{Expectation helpers for testing your jsonapi compliant api}
  spec.homepage      = "http://ross-hunter.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "airborne", "~> 0.2.12"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
