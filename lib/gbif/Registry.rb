require "faraday"
require 'faraday_middleware'
require "multi_json"
require "gbif/error"
require "gbif/request"
require "gbif/constants"
require 'gbif/helpers/configuration'
require 'gbif/faraday'
require 'gbif/utils'
require 'gbif/get_data'

##
# Gbif::Registry
#
# Class to perform HTTP requests to the GBIF API
# @!macro gbif_params
#   @param offset [Fixnum] Number of record to start at, any non-negative integer. Default: 0
#   @param limit [Fixnum] Number of results to return. Default: 100
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
  module Registry
    ##
    # Networks metadata
    #
    # @param data [String] The type of data to get. Default: 'all'
    # @param uuid [String] UUID of the data network provider. This must be specified if data
    #   is anything other than 'all'.
    # @param q [String] Query networks. Only used when 'data = 'all''. Ignored otherwise.
    # @param identifier [fixnum] The value for this parameter can be a simple string or integer,
    #   e.g. identifier=120
    # @param identifierType [String] Used in combination with the identifier parameter to filter
    #   identifiers by identifier type: 'DOI', 'FTP', 'GBIF_NODE', 'GBIF_PARTICIPANT',
    #   'GBIF_PORTAL', 'HANDLER', 'LSID', 'UNKNOWN', 'URI', 'URL', 'UUID'
    # @!macro gbif_params
    # @!macro gbif_options
    #
    # @return [Hash] A hash
    #
    # References: http://www.gbif.org/developer/registry#networks
    #
    # @example
    #
    #      require 'gbif'
    #
    #      registry = Gbif::Registry
    #      registry.networks(limit: 5)
    #      registry.networks(uuid: '16ab5405-6c94-4189-ac71-16ca3b753df7')
    #      registry.networks(data: 'endpoint', uuid: '16ab5405-6c94-4189-ac71-16ca3b753df7')
    def self.networks(data: 'all', uuid: nil, q: nil, identifier: nil,
      identifierType: nil, limit: 100, offset: nil, verbose: nil, options: nil)

        arguments = { q: q,  limit: limit,  offset: offset,  identifier: identifier,
             identifierType: identifierType}.tostrings
        opts = arguments.delete_if { |k, v| v.nil? }

        data_choices = ['all', 'contact', 'endpoint', 'identifier',
            'tag', 'machineTag', 'comment', 'constituents']
        check_data(data, data_choices)
        return self.getdata_networks(data, uuid, opts, verbose, options)
        # if len2(data) == 1
        #     return getdata(data, uuid, args)
        # else
        #     return [getdata(x, uuid, args) for x in data]
        # end
    end

    ##
    # Nodes metadata
    #
    # @param data [String] The type of data to get. Default: 'all'
    # @param uuid [String] UUID of the data node provider. This must be specified if data
    #   is anything other than 'all'.
    # @param q [String] Query nodes. Only used when 'data = 'all''
    # @param identifier [fixnum] The value for this parameter can be a simple string or integer,
    #   e.g. identifier=120
    # @param identifierType [String] Used in combination with the identifier parameter to filter
    #   identifiers by identifier type: 'DOI', 'FTP', 'GBIF_NODE', 'GBIF_PARTICIPANT',
    #   'GBIF_PORTAL', 'HANDLER', 'LSID', 'UNKNOWN', 'URI', 'URL', 'UUID'
    # @param isocode [String] A 2 letter country code. Only used if 'data = 'country''.
    # @!macro gbif_params
    # @!macro gbif_options
    #
    # @return [Hash] A hash
    #
    # References http://www.gbif.org/developer/registry#nodes
    #
    # @example
    #
    #     require 'gbif'
    #
    #     registry = Gbif::Registry
    #     registry.nodes(limit: 5)
    #     registry.nodes(identifier: 120)
    #     registry.nodes(uuid: "1193638d-32d1-43f0-a855-8727c94299d8")
    #     registry.nodes(data: 'identifier', uuid: "03e816b3-8f58-49ae-bc12-4e18b358d6d9")
    #     # FIXME: not working yet
    #     # registry.nodes(data: ['identifier','organization','comment'], uuid: "03e816b3-8f58-49ae-bc12-4e18b358d6d9")
    #
    #
    #     uuids = ["8cb55387-7802-40e8-86d6-d357a583c596","02c40d2a-1cba-4633-90b7-e36e5e97aba8",
    #          "7a17efec-0a6a-424c-b743-f715852c3c1f","b797ce0f-47e6-4231-b048-6b62ca3b0f55",
    #          "1193638d-32d1-43f0-a855-8727c94299d8","d3499f89-5bc0-4454-8cdb-60bead228a6d",
    #          "cdc9736d-5ff7-4ece-9959-3c744360cdb3","a8b16421-d80b-4ef3-8f22-098b01a89255",
    #          "8df8d012-8e64-4c8a-886e-521a3bdfa623","b35cf8f1-748d-467a-adca-4f9170f20a4e",
    #          "03e816b3-8f58-49ae-bc12-4e18b358d6d9","073d1223-70b1-4433-bb21-dd70afe3053b",
    #          "07dfe2f9-5116-4922-9a8a-3e0912276a72","086f5148-c0a8-469b-84cc-cce5342f9242",
    #          "0909d601-bda2-42df-9e63-a6d51847ebce","0e0181bf-9c78-4676-bdc3-54765e661bb8",
    #          "109aea14-c252-4a85-96e2-f5f4d5d088f4","169eb292-376b-4cc6-8e31-9c2c432de0ad",
    #          "1e789bc9-79fc-4e60-a49e-89dfc45a7188","1f94b3ca-9345-4d65-afe2-4bace93aa0fe"]
    #
    #     # [ registry.nodes(data: 'identifier', uuid: x) for x in uuids ] # not working yet
    def self.nodes(data: 'all', uuid: nil, q: nil, identifier: nil,
      identifierType: nil, limit: 100, offset: nil, isocode: nil,
      verbose: nil, options: nil)

        arguments = { q: q, limit: limit, offset: offset, identifier: identifier,
            identifierType: identifierType }.tostrings
        opts = arguments.delete_if { |k, v| v.nil? }
        data_choices = ['all', 'organization', 'endpoint',
            'identifier', 'tag', 'machineTag', 'comment',
            'pendingEndorsement', 'country', 'dataset', 'installation']
        check_data(data, data_choices)
        return self.getdata_nodes(data, uuid, opts, isocode, verbose, options)
        # if len2(data) == 1
        #   return self.getdata_nodes(data, uuid, args)
        # else
        #   return [self.getdata_nodes(x, uuid, args) for x in data]
        # end
    end

  end
end
