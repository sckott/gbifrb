require "gbifrb"
require 'fileutils'
require "test/unit"
require "json"
require_relative "test-helper"

class TestOccurrencesSearch < Test::Unit::TestCase

  def setup
    @occ = Gbif::Occurrences
  end

  def test_search
    VCR.use_cassette("test_search") do
      res = @occ.search(taxonKey: 3329049)
      assert_equal(6, res.length)
      assert_equal(Hash, res.class)
      assert_equal(["offset", "limit", "endOfRecords", "count", "results", "facets"], res.keys)
    end
  end

  def test_search_limit
    VCR.use_cassette("test_search_limit") do
      res2 = @occ.search(limit: 2)
      assert_equal(2, res2['results'].length)

      res3 = @occ.search(limit: 3)
      assert_equal(3, res3['results'].length)
    end
  end

  def test_search_more_than1
    VCR.use_cassette("test_search_more_than1") do
      res = @occ.search(catalogNumber: ["49366","Bird.27847588"], limit: 100)
      catnums = res['results'].collect { |k,v| k['catalogNumber'] }
      assert_equal(6, res.length)
      assert_equal(Hash, res.class)
      assert_true(catnums.uniq.include? "49366")
    end
  end

end
