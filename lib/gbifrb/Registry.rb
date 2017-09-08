require "faraday"
require 'faraday_middleware'
require "multi_json"
require "gbifrb/error"
require "gbifrb/request"
require "gbifrb/constants"
require 'gbifrb/helpers/configuration'
require 'gbifrb/faraday'
require 'gbifrb/utils'
require 'gbifrb/get_data'

##
# Gbif::Registry
#
# Class to perform HTTP requests to the GBIF API
# @!macro gbif_params
#   @param offset [Fixnum] Number of record to start at, any non-negative integer. Default: 0
#   @param limit [Fixnum] Number of results to return. Default: 100
#   @param verbose [Boolean] Print request headers to stdout. Default: false
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
    #      require 'gbifrb'
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
    #     require 'gbifrb'
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

    ##
    # Organizations metadata
    #
    # @param data [String] The type of data to get. Default is all data. If not 'all', then one
    #     or more of 'contact', 'endpoint', 'identifier', 'tag', 'machineTag',
    #     'comment', 'hostedDataset', 'ownedDataset', 'deleted', 'pending',
    #     'nonPublishing'.
    # @param uuid [String] UUID of the data node provider. This must be specified if data
    #     is anything other than 'all'.
    # @param q [String] Query nodes. Only used when 'data='all''. Ignored otherwise.
    # @param identifier [fixnum] The value for this parameter can be a simple string or integer,
    #      e.g. identifier=120
    # @param identifierType [String] Used in combination with the identifier parameter to filter
    #      identifiers by identifier type: 'DOI', 'FTP', 'GBIF_NODE', 'GBIF_PARTICIPANT',
    #      'GBIF_PORTAL', 'HANDLER', 'LSID', 'UNKNOWN', 'URI', 'URL', 'UUID'
    # @!macro gbif_params
    # @!macro gbif_options
    #
    # @return [Hash] a hash
    #
    # References: http://www.gbif.org/developer/registry#organizations
    #
    # @example
    #
    #      require 'gbifrb'
    #
    #      registry = Gbif::Registry
    #      registry.organizations(limit: 5)
    #      registry.organizations(q: "france")
    #      registry.organizations(identifier: 120)
    #      registry.organizations(uuid: "e2e717bf-551a-4917-bdc9-4fa0f342c530")
    #      registry.organizations(data: 'contact', uuid: "e2e717bf-551a-4917-bdc9-4fa0f342c530")
    #      registry.organizations(data: 'endpoint', uuid: "e2e717bf-551a-4917-bdc9-4fa0f342c530")
    #      registry.organizations(data: 'deleted')
    #      registry.organizations(data: 'deleted', limit: 2)
    #      registry.organizations(identifierType: 'DOI', limit: 2)
    #      # FIXME: doesn't work yet
    #      # registry.organizations(data: ['deleted','nonPublishing'], limit: 2)
    def self.organizations(data: 'all', uuid: nil, q: nil, identifier: nil,
      identifierType: nil, limit: 100, offset: nil,
      verbose: nil, options: nil)

        arguments = { q: q, limit: limit, offset: offset, identifier: identifier,
            identifierType: identifierType }.tostrings
        opts = arguments.delete_if { |k, v| v.nil? }
        data_choices = ['all', 'contact', 'endpoint',
            'identifier', 'tag', 'machineTag', 'comment', 'hostedDataset',
            'ownedDataset', 'deleted', 'pending', 'nonPublishing']
        check_data(data, data_choices)
        self.getdata_orgs(data, uuid, opts, verbose, options)
        # if len2(data) == 1
        #     return self.getdata_orgs(data, uuid, args, **kwargs)
        # else
        #     return [self.getdata_orgs(x, uuid, args, **kwargs) for x in data]
        # end
    end

    ##
    # Installations metadata.
    #
    # @param data [String] The type of data to get. Default is all data. If not 'all', then one
    #   or more of 'contact', 'endpoint', 'dataset', 'comment', 'deleted', 'nonPublishing'.
    # @param uuid [String] UUID of the data node provider. This must be specified if data
    #   is anything other than 'all'.
    # @param q [String] Query nodes. Only used when 'data='all''. Ignored otherwise.
    # @param identifier [fixnum] The value for this parameter can be a simple string or integer,
    #    e.g. identifier=120
    # @param identifierType [String] Used in combination with the identifier parameter to filter
    #    identifiers by identifier type: 'DOI', 'FTP', 'GBIF_NODE', 'GBIF_PARTICIPANT',
    #    'GBIF_PORTAL', 'HANDLER', 'LSID', 'UNKNOWN', 'URI', 'URL', 'UUID'
    # @!macro gbif_params
    # @!macro gbif_options
    #
    # @return [Hash] a hash
    #
    # References: http://www.gbif.org/developer/registry#installations
    #
    # @example
    #
    #    require 'gbifrb'
    #
    #    registry = Gbif::Registry
    #    registry.installations(limit: 5)
    #    registry.installations(q: "france")
    #    registry.installations(uuid: "b77901f9-d9b0-47fa-94e0-dd96450aa2b4")
    #    registry.installations(data: 'contact', uuid: "b77901f9-d9b0-47fa-94e0-dd96450aa2b4")
    #    registry.installations(data: 'contact', uuid: "2e029a0c-87af-42e6-87d7-f38a50b78201")
    #    registry.installations(data: 'endpoint', uuid: "b77901f9-d9b0-47fa-94e0-dd96450aa2b4")
    #    registry.installations(data: 'dataset', uuid: "b77901f9-d9b0-47fa-94e0-dd96450aa2b4")
    #    registry.installations(data: 'deleted')
    #    registry.installations(data: 'deleted', limit: 2)
    #    registry.installations(identifierType: 'DOI', limit: 2)
    #    # FIXME: doesn't work yet
    #    # registry.installations(data: ['deleted','nonPublishing'], limit: 2)
    def self.installations(data: 'all', uuid: nil, q: nil, identifier: nil,
      identifierType: nil, limit: 100, offset: nil, verbose: nil, options: nil)

        arguments = { q: q, limit: limit, offset: offset, identifier: identifier,
            identifierType: identifierType }.tostrings
        opts = arguments.delete_if { |k, v| v.nil? }
        data_choices = ['all', 'contact', 'endpoint', 'dataset',
            'identifier', 'tag', 'machineTag', 'comment',
            'deleted', 'nonPublishing']
        check_data(data, data_choices)
        self.getdata_installations(data, uuid, opts, verbose, options)
        # if len2(data) == 1
        #     return self.getdata_installations(data, uuid, opts, verbose, options)
        #   else
        #     return [self.getdata_installations(x, uuid, opts, verbose, options) for x in data]
        # end
    end

    ##
    # Get details on a GBIF dataset.
    #
    # @param uuid [String] One or more dataset UUIDs. See examples.
    # @!macro gbif_options
    #
    # References: http://www.gbif.org/developer/registry#datasetMetrics
    #
    # @example
    #
    #       require 'gbifrb'
    #
    #       registry = Gbif::Registry
    #       registry.dataset_metrics(uuid: '3f8a1297-3259-4700-91fc-acc4170b27ce')
    #       registry.dataset_metrics(uuid: '66dd0960-2d7d-46ee-a491-87b9adcfe7b1')
    #       # registry.dataset_metrics(uuid: ['3f8a1297-3259-4700-91fc-acc4170b27ce', '66dd0960-2d7d-46ee-a491-87b9adcfe7b1'])
    def self.dataset_metrics(uuid:, verbose: nil, options: nil)
        if len2(uuid) == 1
            return self.getdata_dataset_metrics(uuid, verbose, options)
        else
            raise "not ready yet"
            # return [self.getdata_dataset_metrics(x, verbose, options) for x in uuid]
        end
    end

    ##
    # Search for datasets and dataset metadata.
    #
    # @param data [String] The type of data to get. Default: 'all'
    # @param type [String] Type of dataset, options include 'OCCURRENCE', etc.
    # @param uuid [String] UUID of the data node provider. This must be specified if data
    #     is anything other than 'all'.
    # @param query [String] Query term(s). Only used when 'data = 'all''
    # @param id [int] A metadata document id.
    # @!macro gbif_params
    # @!macro gbif_options
    #
    # References http://www.gbif.org/developer/registry#datasets
    #
    # @example
    #
    #       require 'gbifrb'
    #
    #       registry = Gbif::Registry
    #       registry.datasets(limit: 5)
    #       registry.datasets(type: "OCCURRENCE")
    #       registry.datasets(uuid: "a6998220-7e3a-485d-9cd6-73076bd85657")
    #       registry.datasets(data: 'contact', uuid: "a6998220-7e3a-485d-9cd6-73076bd85657")
    #       registry.datasets(data: 'metadata', uuid: "a6998220-7e3a-485d-9cd6-73076bd85657")
    #       registry.datasets(data: 'metadata', uuid: "a6998220-7e3a-485d-9cd6-73076bd85657", id: 598)
    #       # registry.datasets(data: ['deleted','duplicate'])
    #       # registry.datasets(data: ['deleted','duplicate'], limit=1)
    def self.datasets(data: 'all', type: nil, uuid: nil, query: nil, id: nil,
        limit: 100, offset: nil, verbose: nil, options: nil)

        arguments = { q: query, type: type, limit: limit, offset: offset}.tostrings
        opts = arguments.delete_if { |k, v| v.nil? }
        data_choices = ['all', 'organization', 'contact', 'endpoint',
            'identifier', 'tag', 'machinetag', 'comment',
            'constituents', 'document', 'metadata', 'deleted',
            'duplicate', 'subDataset', 'withNoEndpoint']
        check_data(data, data_choices)
        if len2(data) == 1
            return self.datasets_fetch(data, uuid, opts, verbose, options)
        else
            raise "not ready yet"
            # return [self.datasets_fetch(x, uuid, args, **kwargs) for x in data]
        end
    end

    ##
    # Search that returns up to 20 matching datasets. Results are ordered by relevance.
    #
    # @param q [String] Query term(s) for full text search.  The value for this parameter can be a simple word or a phrase. Wildcards can be added to the simple word parameters only, e.g. 'q=*puma*'
    # @param type [String] Type of dataset, options include OCCURRENCE, etc.
    # @param keyword [String] Keyword to search by. Datasets can be tagged by keywords, which you can search on. The search is done on the merged collection of tags, the dataset keywordCollections and temporalCoverages. SEEMS TO NOT BE WORKING ANYMORE AS OF 2016-09-02.
    # @param owningOrg [String] Owning organization. A uuid string. See :func:`~pygbif.registry.organizations`
    # @param publishingOrg [String] Publishing organization. A uuid string. See :func:`~pygbif.registry.organizations`
    # @param hostingOrg [String] Hosting organization. A uuid string. See :func:`~pygbif.registry.organizations`
    # @param publishingCountry [String] Publishing country.
    # @param decade [String] Decade, e.g., 1980. Filters datasets by their temporal coverage broken down to decades. Decades are given as a full year, e.g. 1880, 1960, 2000, etc, and will return datasets wholly contained in the decade as well as those that cover the entire decade or more. Facet by decade to get the break down, e.g. '/search?facet=DECADE&facet_only=true' (see example below)
    # @param limit [int] Number of results to return. Default: '300'
    # @param offset [int] Record to start at. Default: '0'
    # @!macro gbif_options
    #
    # @return [Hash] a hash
    #
    # References: http://www.gbif.org/developer/registry#datasetSearch
    #
    # @example
    #
    #       require 'gbifrb'
    #
    #       registry = Gbif::Registry
    #       registry.dataset_suggest(q: "Amazon", type: "OCCURRENCE")
    #
    #       # Suggest datasets tagged with keyword "france".
    #       registry.dataset_suggest(keyword: "france")
    #
    #       # Suggest datasets owned by the organization with key
    #       # "07f617d0-c688-11d8-bf62-b8a03c50a862" (UK NBN).
    #       registry.dataset_suggest(owningOrg: "07f617d0-c688-11d8-bf62-b8a03c50a862")
    #
    #       # Fulltext search for all datasets having the word "amsterdam" somewhere in
    #       # its metadata (title, description, etc).
    #       registry.dataset_suggest(q: "amsterdam")
    #
    #       # Limited search
    #       registry.dataset_suggest(type: "OCCURRENCE", limit: 2)
    #       registry.dataset_suggest(type: "OCCURRENCE", limit: 2, offset: 10)
    #
    #       # Return just descriptions
    #       registry.dataset_suggest(type: "OCCURRENCE", limit:  5, description: True)
    #
    #       # Search by decade
    #       registry.dataset_suggest(decade: 1980, limit:  30)
    def self.dataset_suggest(q: nil, type: nil, keyword: nil, owningOrg: nil,
        publishingOrg: nil, hostingOrg: nil, publishingCountry: nil, decade: nil,
        limit: 100, offset: nil, verbose: nil, options: nil)

        arguments = { q: q,  type: type,  keyword: keyword,
             publishingOrg: publishingOrg,  hostingOrg: hostingOrg,
             owningOrg: owningOrg,  decade: decade,
             publishingCountry: publishingCountry,
             limit: limit,  offset: offset}.tostrings
        opts = arguments.delete_if { |k, v| v.nil? }
        Request.new('dataset/suggest', opts, verbose, options).perform
    end

    ##
    # Full text search across all datasets. Results are ordered by relevance.
    #
    # @param q [String] Query term(s) for full text search.  The value for this parameter
    #      can be a simple word or a phrase. Wildcards can be added to the simple word
    #      parameters only, e.g. 'q=*puma*'
    # @param type [String] Type of dataset, options include OCCURRENCE, etc.
    # @param keyword [String] Keyword to search by. Datasets can be tagged by keywords, which
    #      you can search on. The search is done on the merged collection of tags, the
    #      dataset keywordCollections and temporalCoverages. SEEMS TO NOT BE WORKING
    #      ANYMORE AS OF 2016-09-02.
    # @param owningOrg [String] Owning organization. A uuid string. See :func:`~pygbif.registry.organizations`
    # @param publishingOrg [String] Publishing organization. A uuid string. See :func:`~pygbif.registry.organizations`
    # @param hostingOrg [String] Hosting organization. A uuid string. See :func:`~pygbif.registry.organizations`
    # @param publishingCountry [String] Publishing country.
    # @param decade [String] Decade, e.g., 1980. Filters datasets by their temporal coverage
    #      broken down to decades. Decades are given as a full year, e.g. 1880, 1960, 2000,
    #      etc, and will return datasets wholly contained in the decade as well as those
    #      that cover the entire decade or more. Facet by decade to get the break down,
    #      e.g. '/search?facet=DECADE&facet_only=true' (see example below)
    # @param facet [String] A list of facet names used to retrieve the 100 most frequent values
    #         for a field. Allowed facets are: type, keyword, publishingOrg, hostingOrg, decade,
    #         and publishingCountry. Additionally subtype and country are legal values but not
    #         yet implemented, so data will not yet be returned for them.
    # @param facetMincount [String] Used in combination with the facet parameter. Set
    #         facetMincount={#} to exclude facets with a count less than {#}, e.g.
    #         http://api.gbif.org/v1/dataset/search?facet=type&limit=0&facetMincount=10000
    #         only shows the type value 'OCCURRENCE' because 'CHECKLIST' and 'METADATA' have
    #         counts less than 10000.
    # @param facetMultiselect [bool] Used in combination with the facet parameter. Set
    #         facetMultiselect=True to still return counts for values that are not currently
    #         filtered, e.g.
    #         http://api.gbif.org/v1/dataset/search?facet=type&limit=0&type=CHECKLIST&facetMultiselect=true
    #         still shows type values 'OCCURRENCE' and 'METADATA' even though type is being
    #         filtered by type=CHECKLIST
    # @param hl [bool] Set 'hl=True' to highlight terms matching the query when in fulltext
    #         search fields. The highlight will be an emphasis tag of class 'gbifH1' e.g.
    #         http://api.gbif.org/v1/dataset/search?q=plant&hl=true
    #         Fulltext search fields include: title, keyword, country, publishing country,
    #         publishing organization title, hosting organization title, and description. One
    #         additional full text field is searched which includes information from metadata
    #         documents, but the text of this field is not returned in the response.
    # @param limit [int] Number of results to return. Default: '300'
    # @param offset [int] Record to start at. Default: '0'
    # @!macro gbif_options
    #
    # @note Note that you can pass in additional faceting parameters on a per field basis.
    #         For example, if you want to limit the numbef of facets returned from a field 'foo' to
    #         3 results, pass in 'foo_facetLimit = 3'. GBIF does not allow all per field parameters,
    #         but does allow some. See also examples.
    #
    # @return [Hash] a hash
    #
    # References: http://www.gbif.org/developer/registry#datasetSearch
    #
    # @example
    #
    #         require 'gbifrb'
    #
    #         registry = Gbif::Registry
    #
    #         # Gets all datasets of type "OCCURRENCE".
    #         registry.dataset_search(type: "OCCURRENCE", limit:  10)
    #
    #         # Fulltext search for all datasets having the word "amsterdam" somewhere in
    #         # its metadata (title, description, etc).
    #         registry.dataset_search(q: "amsterdam", limit:  10)
    #
    #         # Limited search
    #         registry.dataset_search(type: "OCCURRENCE", limit: 2)
    #         registry.dataset_search(type: "OCCURRENCE", limit: 2, offset: 10)
    #
    #         # Search by decade
    #         registry.dataset_search(decade: 1980, limit:  10)
    #
    #         # Faceting
    #         ## just facets
    #         registry.dataset_search(facet: "decade", facetMincount: 10, limit: 0)
    #
    #         ## data and facets
    #         registry.dataset_search(facet: "decade", facetMincount: 10, limit: 2)
    #
    #         ## many facet variables
    #         registry.dataset_search(facet: ["decade", "type"], facetMincount: 10, limit: 0)
    #
    #         ## facet vars
    #         ### per variable paging
    #         registry.dataset_search(
    #             facet: ["decade", "type"],
    #             decade_facetLimit: 3,
    #             type_facetLimit: 3,
    #             limit: 0
    #         )
    #
    #         ## highlight
    #         registry.dataset_search(q: "plant", hl: True, limit :  10)
    def self.dataset_search(q: nil, type: nil, keyword: nil,
        owningOrg: nil, publishingOrg: nil, hostingOrg: nil, decade: nil,
        publishingCountry: nil, facet: nil, facetMincount: nil,
        facetMultiselect: nil, hl: false, limit: 100, offset: nil,
        verbose: nil, options: nil)

        arguments = {q: q, type: type, keyword: keyword,
                    owningOrg: owningOrg, publishingOrg: publishingOrg,
                    hostingOrg: hostingOrg, decade: decade,
                    publishingCountry: publishingCountry, facet: facet,
                    facetMincount: facetMincount, facetMultiselect: facetMultiselect,
                    hl: hl, limit: limit, offset: offset}.tostrings
        opts = arguments.delete_if { |k, v| v.nil? }
        Request.new('dataset/search', opts, verbose, options).perform
    end

  end
end
