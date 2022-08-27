# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gbifrb/version'

Gem::Specification.new do |s|
  s.name        = 'gbifrb'
  s.version     = Gbif::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.0'
  s.date        = '2022-08-27'
  s.summary     = "GBIF Client"
  s.description = "Low Level Ruby Client for the GBIF API"
  s.authors     = "Scott Chamberlain"
  s.email       = 'myrmecocystus@gmail.com'
  s.homepage    = 'https://github.com/sckott/gbifrb'
  s.licenses    = 'MIT'

  s.files = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'bundler', '~> 2.2', '>= 2.2.1'
  s.add_development_dependency 'rake', '~> 13.0', '>= 13.0.1'
  s.add_development_dependency 'test-unit', '~> 3.3', '>= 3.3.7'
  s.add_development_dependency 'simplecov', '~> 0.21.2'
  s.add_development_dependency 'codecov', '~> 0.6.0'
  s.add_development_dependency 'json', '~> 2.6.1'
  s.add_development_dependency 'vcr', '~> 6.0'
  s.add_development_dependency 'webmock', '~> 3.16.0'
end
