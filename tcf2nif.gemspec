# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tcf2nif/version'

Gem::Specification.new do |spec|
  spec.name          = "tcf2nif"
  spec.version       = Tcf2Nif::VERSION
  spec.authors       = ["Peter Menke"]
  spec.email         = ["pmenke@googlemail.com"]

  spec.summary       = %q{A small NLP data converter from the TCF to the NIF format}
  spec.description   = %q{tcf2nif converts NLP data from the TCF format (used by WebLicht) to the RDF-based NIF format.}
  spec.homepage      = "http://github.com/pmenke/tcf2nif"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "spork"
  spec.add_development_dependency "simplecov"

  spec.add_runtime_dependency 'rdf', '~> 1.1'
  spec.add_runtime_dependency 'nokogiri', '~> 1.6'
  
end
