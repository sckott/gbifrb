require "gbifrb"
require 'fileutils'
require "test/unit"
require "json"
require_relative "test-helper"

class TestSpeciesNameBackbone < Test::Unit::TestCase

  def setup
    @species = Gbif::Species
  end

  def test_name_backbone
    VCR.use_cassette("test_name_backbone") do
      res = @species.name_backbone(name: "Helianthus")
      assert_equal(Hash, res.class)
      assert_equal(3119134, res['usageKey'])
    end
  end

  def test_name_backbone_no_match_multiple
    VCR.use_cassette("test_name_backbone_no_match_multiple") do
      res2 = @species.name_backbone(name: "Helianthu", strict: false)
      assert_equal(Hash, res2.class)
      assert_equal("NONE", res2["matchType"])
      assert_equal("No match because of too little confidence", res2["note"])
    end
  end

  def test_name_backbone_no_match
    VCR.use_cassette("test_name_backbone_no_match") do
      res2 = @species.name_backbone(name: "Helianthu", strict: true)
      assert_equal(Hash, res2.class)
      assert_equal("NONE", res2["matchType"])
    end
  end

end
