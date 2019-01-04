# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gbifrb/version'

Gem::Specification.new do |s|
  s.name        = 'gbifrb'
  s.version     = Gbif::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.0'
  s.date        = '2017-09-07'
  s.summary     = "GBIF Client"
  s.description = "Low Level Ruby Client for the GBIF API"
  s.authors     = "Scott Chamberlain"
  s.email       = 'myrmecocystus@gmail.com'
  s.homepage    = 'https://github.com/sckott/gbifrb'
  s.licenses    = 'MIT'

  s.files = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'bundler', '>= 1.14.6', '~> 2.0'
  s.add_development_dependency 'rake', '~> 12.0', '>= 12.0.0'
  s.add_development_dependency 'test-unit', '~> 3.2', '>= 3.2.1'
  s.add_development_dependency 'simplecov', '~> 0.14.1'
  s.add_development_dependency 'codecov', '~> 0.1.10'
  s.add_development_dependency 'json', '~> 2.0', '>= 2.0.3'
  s.add_development_dependency 'vcr', '~> 3.0', '>= 3.0.3'
  s.add_development_dependency 'webmock', '~> 2.3', '>= 2.3.2'

  s.add_runtime_dependency 'faraday', '~> 0.12.0.1'
  s.add_runtime_dependency 'faraday_middleware', '~> 0.11.0.1'
  s.add_runtime_dependency 'thor', '~> 0.19.4'
  s.add_runtime_dependency 'multi_json', '~> 1.12', '>= 1.12.1'
end
