# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy311/version'

Gem::Specification.new do |gem|
  gem.name          = "easy311"
  gem.version       = Easy311::VERSION
  gem.authors       = ["Jimmy Bourassa", "Gregory Eric Sanderson"]
  gem.email         = ["jimmy.bourassa@hooktstudios.com", "gzou2000@gmail.com"]
  gem.description   = %q{Set of tools to ease the development of Open311 applications}
  gem.summary       = %q{Easy311 is a set of tools to ease the development of
                         Open311 applications: it provides a wrapper around the
                         REST API and a close-to-compliant ActiveModel
                         `Request` object.}
  gem.homepage      = "https://github.com/jbourassa/easy311"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('active_attr')
  gem.add_dependency('rest-client')
end
