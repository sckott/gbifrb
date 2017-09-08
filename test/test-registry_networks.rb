require 'simplecov'
SimpleCov.start
if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "gbifrb"
require 'fileutils'
require "test/unit"
require "json"
require_relative "test-helper"

class TestRegistryNetworks < Test::Unit::TestCase

  def setup
    @registry = Gbif::Registry
  end

  def test_registry_networks
    VCR.use_cassette("test_registry_networks") do
      res = @registry.networks(limit: 5)
      assert_equal(5, res.length)
      assert_equal(Hash, res.class)
      assert_equal(["offset", "limit", "endOfRecords", "count", "results"], res.keys)
    end
  end

end
