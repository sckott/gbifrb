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

class TestSpeciesNameUsage < Test::Unit::TestCase

  def setup
    @species = Gbif::Species
  end

  def test_name_usage
    VCR.use_cassette("test_name_usage") do
      res = @species.name_usage(name: 'Helianthus')['results']
      check = res.map{ |result| result['canonicalName'].downcase.include?('helianthus') }.uniq
      assert_equal(1, check.length)
      assert_equal(true, check[0])
    end
  end

  def test_name_usage_datasetkey
    VCR.use_cassette("test_name_usage_datasetkey") do
      key = '34a96ebe-e51c-4222-9d08-5c2043c39dec'
      response = @species.name_usage(name: 'Helianthus', datasetKey: key)
      res = response['results']
      check = res.map{ |result| result['datasetKey'] }.uniq
      assert_equal(1, check.length)
      assert_equal(key, check[0])
    end
  end

  # sourceId is not documented well anywhere, as far as I can tell
  # it seems to be another name for taxonId, which appears to be specific to a dataset
  # the same taxonID may be used for different taxa in different datasets
  def test_name_usage_sourceid
    VCR.use_cassette("test_name_usage_sourceid") do
      sourceid = '115091'
      response = @species.name_usage(sourceId: sourceid)
      res = response['results']
      taxoncheck = res.map{ |result| result['taxonID'] }.uniq
      kingdomcheck = res.map{ |result| result['kingdom'] }.uniq.compact.sort
      assert_equal(1, taxoncheck.length)
      assert_equal(sourceid, taxoncheck[0])
      assert_operator(kingdomcheck.length, :>, 1)
    end
  end

  def test_name_usage_no_results
    VCR.use_cassette("test_name_usage_no_results") do
      response = @species.name_usage(name: 'Unknown umbellifer')
      res = response['results']
      assert_equal(0, res.length)
    end
  end
end
