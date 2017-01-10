# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lightsaber/version'

Gem::Specification.new do |spec|
  spec.name          = "lightsaber"
  spec.version       = Lightsaber::VERSION
  spec.authors       = ["hiromipaw"]
  spec.email         = ["hiro@torproject.org"]

  spec.summary       = %q{Lightsaber is a cli for Trac wiki and ticketing system using http calls.}
  spec.description   = %q{Lightsaber is a simple wiki for Trac wiki and ticketing system.
                          It uses xmlrpc by wrapping console commands around HTTP protocol calls.}
  spec.homepage      = "https://rubygems.org/gems/lightsaber"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
