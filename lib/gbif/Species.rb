require "faraday"
require 'faraday_middleware'
require "multi_json"
require "gbif/error"
require "gbif/request"
require "gbif/constants"
require 'gbif/helpers/configuration'
require 'gbif/faraday'
require 'gbif/utils'

##
# Gbif::Species
#
# Class to perform HTTP requests to the GBIF API
# @!macro gbif_params
#   @param offset [Fixnum] Number of record to start at, any non-negative integer up to 10,000
#   @param limit [Fixnum] Number of results to return. Not relavant when searching with specific dois.
#       Default: 20. Max: 1000
#   @param sample [Fixnum] Number of random results to return. when you use the sample parameter,
#       the limit and offset parameters are ignored. This parameter only used when works requested.
#       Max: 100.
#   @param sort [String] Field to sort on, one of score, relevance,
#       updated (date of most recent change to metadata - currently the same as deposited),
#       deposited (time of most recent deposit), indexed (time of most recent index), or
#       published (publication date). Note: If the API call includes a query, then the sort
#       order will be by the relevance score. If no query is included, then the sort order
#       will be by DOI update date.
#   @param order [String] Sort order, one of 'asc' or 'desc'
#   @param facet [Boolean/String] Include facet results OR a query (e.g., `license:*`) to facet by
#       license. Default: false
#   @param verbose [Boolean] Print request headers to stdout. Default: false
#
# @!macro gbif_options
#   @param options [Hash] Hash of options for configuring the request, passed on to Faraday.new
#     - timeout [Fixnum] open/read timeout Integer in seconds
#     - open_timeout [Fixnum] read timeout Integer in seconds
#     - proxy [Hash] hash of proxy options
#       - uri [String] Proxy Server URI
#       - user [String] Proxy server username
#       - password [String] Proxy server password
#     - params_encoder [Hash] not sure what this is
#     - bind [Hash] A hash with host and port values
#     - boundary [String] of the boundary value
#     - oauth [Hash] A hash with OAuth details
module Gbif
  class Species

    def initialize
      "methods: name_backbone"
    end

    ##
    # Search the GBIF taxonomic backbone
    #
    # @!macro gbif_params
    # @!macro gbif_options
    # @param ids [Array] DOIs (digital object identifier) or other identifiers
    # @param query [String] A query string
    # @param filter [Hash] Filter options. See ...
    # @param works [Boolean] If true, works returned as well. Default: false
    # @return [Array] An array of hashes
    #
    # @example
    #      require 'gbif'
    #
    #      x = Gbif::Species.new
    #      x.name_backbone("Helianthus")
    #      x.name_backbone("Poa")
    def name_backbone(name, rank = nil, kingdom = nil, phylum = nil,
      clazz = nil, order = nil, family = nil, genus = nil, strict = nil,
      offset = nil, limit = nil, verbose = nil, options = nil)

      arguments = { name: name, rank: rank, kingdom: kingdom,
              phylum: phylum, class: clazz, order: order,
              family: family, genus: genus, strict: strict,
              offset: offset, limit: limit }.tostrings
      opts = arguments.delete_if { |k, v| v.nil? }
      self.exec("species/match", args = opts, verbose = verbose, options = options)
    end

    def name_suggest(q = nil, datasetKey = nil, rank = nil, limit = 100, offset = nil,
      verbose = nil, options = nil)

      arguments = { q: q, datasetKey: datasetKey, rank: rank,
        limit: limit, offset: offset }.tostrings
      opts = arguments.delete_if { |k, v| v.nil? }
      self.exec("species/suggest", args = opts, verbose = verbose, options = options)
    end

    def name_usage(key = nil, name = nil, data = 'all', language = nil,
      datasetKey = nil, uuid = nil, sourceId = nil, rank = nil, shortname = nil,
      limit = 100, offset = nil, verbose = nil, options = nil)

      arguments = { key: key, name: name, data: data,
        language: language, datasetKey: datasetKey, uuid: uuid,
        sourceId: sourceId, rank: rank, shortname: shortname,
        limit: limit, offset: offset }.tostrings
      opts = arguments.delete_if { |k, v| v.nil? }
      self.exec("species/", args = opts, verbose = verbose, options = options)
    end

    def name_lookup(q = nil, rank = nil, higherTaxonKey = nil, status = nil,
      isExtinct = nil, habitat = nil, nameType = nil, datasetKey = nil,
      nomenclaturalStatus = nil, limit = 100, offset = nil, facet = false,
      facetMincount = nil, facetMultiselect = nil, type = nil, hl = false,
      verbose = nil, options = nil)

      arguments = { q: q, rank: rank, higherTaxonKey: higherTaxonKey,
        status: status, isExtinct: isExtinct, habitat: habitat, nameType: nameType,
        datasetKey: datasetKey, nomenclaturalStatus: nomenclaturalStatus,
        limit: limit, offset: offset, facet: facet, facetMincount: facetMincount,
        facetMultiselect: facetMultiselect, type: type, hl: hl }.tostrings
      opts = arguments.delete_if { |k, v| v.nil? }
      self.exec("species/search", args = opts, verbose = verbose, options = options)
    end

    def exec(endpt, args, verbose, options)
      Request.new(endpt = endpt, args = args, verbose = verbose, options = options).perform
    end

  end
end
