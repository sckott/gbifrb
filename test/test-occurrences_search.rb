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

class TestWorks < Test::Unit::TestCase

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

  # def test_search_query_param
  #   VCR.use_cassette("test_search_query_param") do
  #     res = @occ.search(q: "kingfisher", limit: 20)
  #     assert_equal(6, res.length)
  #     assert_equal(Hash, res.class)
  #   end
  # end

  # def test_search_filter_handler
  #   VCR.use_cassette("test_search_filter_handler") do
  #     res = Serrano.works(filter: {has_funder: true, has_full_text: true})
  #     assert_equal(Hash, res.class)
  #   end
  #   # assert_equal(200, res.status)
  # end

  # def test_search_sort
  #   VCR.use_cassette("test_search_sort") do
  #     res1 = Serrano.works(query: "ecology", sort: 'relevance')
  #     scores = res1['message']['items'].collect { |x| x['score'] }.flatten
  #     res2 = Serrano.works(query: "ecology", sort: 'deposited')
  #     deposited = res2['message']['items'].collect { |x| x['deposited']['date-time'] }.flatten
  #     assert_equal(4, res1.length)
  #     assert_equal(4, res2.length)
  #     assert_equal(Hash, res1.class)
  #     assert_equal(Hash, res2.class)
  #     assert_true(scores.max > scores.min)
  #     assert_true(deposited.max > deposited.min)
  #   end
  # end

  # def test_search_facet
  #   VCR.use_cassette("test_search_facet") do
  #     res = Serrano.works(facet: 'license:*', limit: 0, filter: {has_full_text: true})
  #     assert_equal(4, res.length)
  #     assert_equal(Hash, res.class)
  #     assert_equal(0, res['message']['items'].length)
  #     assert_equal(1, res['message']['facets'].length)
  #     assert_true(res['message']['facets']['license']['values'].length > 100)
  #   end
  # end

  # def test_search_sample
  #   VCR.use_cassette("test_search_sample") do
  #     res = Serrano.works(sample: 3)
  #     assert_equal(4, res.length)
  #     assert_equal(Hash, res.class)
  #     assert_equal(3, res['message']['items'].length)
  #   end
  # end

end
