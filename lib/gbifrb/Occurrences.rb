require "faraday"
require 'faraday_middleware'
require "multi_json"
require "gbifrb/error"
require "gbifrb/request"
require "gbifrb/constants"
require 'gbifrb/helpers/configuration'
require 'gbifrb/faraday'
require 'gbifrb/utils'

##
# Gbif::Occurrences
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
  module Occurrences
    ##
    # Search GBIF occurrences
    #
    # @param taxonKey [int] A GBIF occurrence identifier
    # @param q [String] Simple search parameter. The value for this parameter can be a simple word or a phrase.
    # @param spellCheck [bool] If 'true' ask GBIF to check your spelling of the value passed to the 'search' parameter.
    #       IMPORTANT: This only checks the input to the 'search' parameter, and no others. Default: 'false'
    # @param repatriated [String] Searches for records whose publishing country is different to the country where the record was recorded in
    # @param kingdomKey [int] Kingdom classification key
    # @param phylumKey [int] Phylum classification key
    # @param classKey [int] Class classification key
    # @param orderKey [int] Order classification key
    # @param familyKey [int] Family classification key
    # @param genusKey [int] Genus classification key
    # @param subgenusKey [int] Subgenus classification key
    # @param scientificName [String] A scientific name from the GBIF backbone. All included and synonym taxa are included in the search.
    # @param datasetKey [String] The occurrence dataset key (a uuid)
    # @param catalogNumber [String] An identifier of any form assigned by the source within a physical collection or digital dataset for the record which may not unique, but should be fairly unique in combination with the institution and collection code.
    # @param recordedBy [String] The person who recorded the occurrence.
    # @param collectionCode [String] An identifier of any form assigned by the source to identify the physical collection or digital dataset uniquely within the text of an institution.
    # @param institutionCode [String] An identifier of any form assigned by the source to identify the institution the record belongs to. Not guaranteed to be que.
    # @param country [String] The 2-letter country code (as per ISO-3166-1) of the country in which the occurrence was recorded. See here http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
    # @param basisOfRecord [String] Basis of record, as defined in our BasisOfRecord enum here http://gbif.github.io/gbif-api/apidocs/org/gbifrb/api/vocabulary/BasisOfRecord.html Acceptable values are:
    #    - 'FOSSIL_SPECIMEN' An occurrence record describing a fossilized specimen.
    #    - 'HUMAN_OBSERVATION' An occurrence record describing an observation made by one or more people.
    #    - 'LITERATURE' An occurrence record based on literature alone.
    #    - 'LIVING_SPECIMEN' An occurrence record describing a living specimen, e.g.
    #    - 'MACHINE_OBSERVATION' An occurrence record describing an observation made by a machine.
    #    - 'OBSERVATION' An occurrence record describing an observation.
    #    - 'PRESERVED_SPECIMEN' An occurrence record describing a preserved specimen.
    #    - 'UNKNOWN' Unknown basis for the record.
    ## @param eventDate [date] Occurrence date in ISO 8601 format: yyyy, yyyy-MM, yyyy-MM-dd, or
    #      MM-dd. Supports range queries, smaller,larger (e.g., '1990,1991', whereas '1991,1990'
    #      wouldn't work)
    # @param year [int] The 4 digit year. A year of 98 will be interpreted as AD 98. Supports range queries,
    #      smaller,larger (e.g., '1990,1991', whereas '1991,1990' wouldn't work)
    # @param month [int] The month of the year, starting with 1 for January. Supports range queries,
    #      smaller,larger (e.g., '1,2', whereas '2,1' wouldn't work)
    # @param decimalLatitude [float] Latitude in decimals between -90 and 90 based on WGS 84.
    #      Supports range queries, smaller,larger (e.g., '25,30', whereas '30,25' wouldn't work)
    # @param decimalLongitude [float] Longitude in decimals between -180 and 180 based on WGS 84.
    #      Supports range queries (e.g., '-0.4,-0.2', whereas '-0.2,-0.4' wouldn't work).
    # @param publishingCountry [String] The 2-letter country code (as per ISO-3166-1) of the
    #      country in which the occurrence was recorded.
    # @param elevation [int/str] Elevation in meters above sea level. Supports range queries, smaller,larger
    #      (e.g., '5,30', whereas '30,5' wouldn't work)
    # @param depth [int/str] Depth in meters relative to elevation. For example 10 meters below a
    #      lake surface with given elevation. Supports range queries, smaller,larger (e.g., '5,30',
    #      whereas '30,5' wouldn't work)
    # @param geometry [String] Searches for occurrences inside a polygon described in Well Known
    #      Text (WKT) format. A WKT shape written as either POINT, LINESTRING, LINEARRING
    #      POLYGON, or MULTIPOLYGON. Example of a polygon: '((30.1 10.1, 20, 20 40, 40 40, 30.1 10.1))' would be queried as http://bit.ly/1BzNwDq.
    # @param hasGeospatialIssue [bool] Includes/excludes occurrence records which contain spatial
    #      issues (as determined in our record interpretation), i.e. 'hasGeospatialIssue=TRUE'
    #      returns only those records with spatial issues while 'hasGeospatialIssue=FALSE' includes
    #      only records without spatial issues. The absence of this parameter returns any
    #      record with or without spatial issues.
    # @param issue [String] One or more of many possible issues with each occurrence record. See
    #      Details. Issues passed to this parameter filter results by the issue.
    # @param hasCoordinate [bool] Return only occurence records with lat/long data ('true') or
    #      all records ('false', default).
    # @param typeStatus [String] Type status of the specimen. One of many options. See ?typestatus
    # @param recordNumber [int] Number recorded by collector of the data, different from GBIF record
    #      number. See http://rs.tdwg.org/dwc/terms/#recordNumber} for more info
    # @param lastInterpreted [date] Date the record was last modified in GBIF, in ISO 8601 format:
    #      yyyy, yyyy-MM, yyyy-MM-dd, or MM-dd.  Supports range queries, smaller,larger (e.g.,
    #      '1990,1991', whereas '1991,1990' wouldn't work)
    # @param continent [String] Continent. One of 'africa', 'antarctica', 'asia', 'europe', 'north_america'
    #      (North America includes the Caribbean and reachies down and includes Panama), 'oceania',
    #      or 'south_america'
    # @param mediatype [String] Media type. Default is 'NULL', so no filtering on mediatype. Options:
    #      'NULL', 'MovingImage', 'Sound', and 'StillImage'
    # @param limit [int] Number of results to return. Default: '300'
    # @param offset [int] Record to start at. Default: '0'
    # @param verbose [Boolean] Print request headers to stdout. Default: false
    # @param facet [String] a character vector of length 1 or greater
    # @param establishmentMeans [String] EstablishmentMeans, possible values include: INTRODUCED,
    #       INVASIVE, MANAGED, NATIVE, NATURALISED, UNCERTAIN
    # @param facetMincount [int] minimum number of records to be included in the faceting results
    # @param facetMultiselect [bool] Set to 'true' to still return counts for values that are not currently
    #       filtered. See examples. Default: 'false'
    # @!macro gbif_options
    #
    # @return [Hash] A hash
    #
    # @example
    #       require 'gbif'
    #       occ = Gbif::Occurrences
    #
    #       occ.search(taxonKey: 3329049)
    #       # Return 2 results, this is the default by the way
    #       occ.search(taxonKey: 3329049, limit: 2)
    #       # Instead of getting a taxon key first, you can search for a name directly
    #       # However, note that using this approach (with `scientificName="..."`)
    #       # you are getting synonyms too. The results for using `scientifcName` and
    #       # `taxonKey` parameters are the same in this case, but I wouldn't be surprised if for some
    #       # names they return different results
    #       occ.search(scientificName: 'Ursus americanus')
    #       species = Gbif::Species
    #       key = species.name_backbone(name: 'Ursus americanus', rank: 'species')['usageKey']
    #       occ.search(taxonKey: key)
    #       # Search by dataset key
    #       occ.search(datasetKey: '7b5d6a48-f762-11e1-a439-00145eb45e9a', limit: 20)
    #       # Search by catalog number
    #       occ.search(catalogNumber: "49366", limit: 20)
    #       # occ.search(catalogNumber: ["49366","Bird.27847588"], limit: 20)
    #       # Use paging parameters (limit and offset) to page. Note the different results
    #       # for the two queries below.
    #       occ.search(datasetKey: '7b5d6a48-f762-11e1-a439-00145eb45e9a', offset: 10, limit: 5)
    #       occ.search(datasetKey: '7b5d6a48-f762-11e1-a439-00145eb45e9a', offset: 20, limit: 5)
    #       # Many dataset keys
    #       # occ.search(datasetKey: ["50c9509d-22c7-4a22-a47d-8c48425ef4a7", "7b5d6a48-f762-11e1-a439-00145eb45e9a"], limit: 20)
    #       # Search by collector name
    #       res = occ.search(recordedBy: "smith", limit: 20)
    #       [ x['recordedBy'] for x in res['results'] ]
    #       # Many collector names
    #       # occ.search(recordedBy: ["smith","BJ Stacey"], limit: 20)
    #       # Search for many species
    #       splist = ['Cyanocitta stelleri', 'Junco hyemalis', 'Aix sponsa']
    #       keys = [ species.name_suggest(x)[0]['key'] for x in splist ]
    #       out = [ occ.search(taxonKey: x, limit: 1) for x in keys ]
    #       [ x['results'][0]['speciesKey'] for x in out ]
    #       # Search - q parameter
    #       occ.search(q: "kingfisher", limit: 20)
    #       ## spell check - only works with the `search` parameter
    #       ### spelled correctly - same result as above call
    #       occ.search(q: "kingfisher", limit: 20, spellCheck: true)
    #       ### spelled incorrectly - stops with suggested spelling
    #       occ.search(q: "kajsdkla", limit: 20, spellCheck: true)
    #       ### spelled incorrectly - stops with many suggested spellings
    #       ###   and number of results for each
    #       occ.search(q: "helir", limit: 20, spellCheck: true)
    #       # Search on latitidue and longitude
    #       occ.search(decimalLatitude: 50, decimalLongitude: 10, limit: 2)
    #       # Search on a bounding box
    #       ## in well known text format
    #       occ.search(geometry: 'POLYGON((30.1 10.1, 10 20, 20 40, 40 40, 30.1 10.1))', limit: 20)
    #       species = Gbif::Species
    #       key = species.name_suggest(q: 'Aesculus hippocastanum')[0]['key']
    #       occ.search(taxonKey: key, geometry: 'POLYGON((30.1 10.1, 10 20, 20 40, 40 40, 30.1 10.1))', limit: 20)
    #       ## multipolygon
    #       wkt = 'MULTIPOLYGON(((-123 38, -123 43, -116 43, -116 38, -123 38)),((-97 41, -97 45, -93 45, -93 41, -97 41)))'
    #       occ.search(geometry: wkt, limit: 20)
    #       # Search on country
    #       occ.search(country: 'US', limit: 20)
    #       occ.search(country: 'FR', limit: 20)
    #       occ.search(country: 'DE', limit: 20)
    #       # Get only occurrences with lat/long data
    #       occ.search(taxonKey: key, hasCoordinate: true, limit: 20)
    #       # Get only occurrences that were recorded as living specimens
    #       occ.search(taxonKey: key, basisOfRecord: "LIVING_SPECIMEN", hasCoordinate: true, limit: 20)
    #       # Get occurrences for a particular eventDate
    #       occ.search(taxonKey: key, eventDate: "2013", limit: 20)
    #       occ.search(taxonKey: key, year: "2013", limit: 20)
    #       occ.search(taxonKey: key, month: "6", limit: 20)
    #
    #       # Get occurrences based on depth
    #       key = species.name_backbone(name: 'Salmo salar', kingdom: 'animals')['usageKey']
    #       occ.search(taxonKey: key, depth: "5", limit: 20)
    #
    #       # Get occurrences based on elevation
    #       key = species.name_backbone(name: 'Puma concolor', kingdom: 'animals')['usageKey']
    #       occ.search(taxonKey: key, elevation: 50, hasCoordinate: true, limit: 20)
    #
    #       # Get occurrences based on institutionCode
    #       occ.search(institutionCode: "TLMF", limit: 20)
    #
    #       # Get occurrences based on collectionCode
    #       occ.search(collectionCode: "Floristic Databases MV - Higher Plants", limit: 20)
    #
    #       # Get only those occurrences with spatial issues
    #       occ.search(taxonKey: key, hasGeospatialIssue: true, limit: 20)
    #
    #       # Search using a query string
    #       occ.search(q: "kingfisher", limit: 20)
    #
    #       # Range queries
    #       ## See Detail for parameters that support range queries
    #       ### this is a range depth, with lower/upper limits in character string
    #       occ.search(depth: '50,100')
    #
    #       ## Range search with year
    #       occ.search(year: '1999,2000', limit: 20)
    #
    #       ## Range search with latitude
    #       occ.search(decimalLatitude: '29.59,29.6')
    #
    #       # Search by specimen type status
    #       ## Look for possible values of the typeStatus parameter looking at the typestatus dataset
    #       occ.search(typeStatus: 'allotype')
    #
    #       # Search by specimen record number
    #       ## This is the record number of the person/group that submitted the data, not GBIF's numbers
    #       ## You can see that many different groups have record number 1, so not super helpful
    #       occ.search(recordNumber: 1)
    #
    #       # Search by last time interpreted: Date the record was last modified in GBIF
    #       ## The lastInterpreted parameter accepts ISO 8601 format dates, including
    #       ## yyyy, yyyy-MM, yyyy-MM-dd, or MM-dd. Range queries are accepted for lastInterpreted
    #       occ.search(lastInterpreted: '2014-04-01')
    #
    #       # Search by continent
    #       ## One of africa, antarctica, asia, europe, north_america, oceania, or south_america
    #       occ.search(continent: 'south_america')
    #       occ.search(continent: 'africa')
    #       occ.search(continent: 'oceania')
    #       occ.search(continent: 'antarctica')
    #
    #       # Search for occurrences with images
    #       occ.search(mediatype: 'StillImage')
    #       occ.search(mediatype: 'MovingImage')
    #       x = occ.search(mediatype: 'Sound')
    #       [z['media'] for z in x['results']]
    #
    #       # Query based on issues
    #       occ.search(taxonKey: 1, issue: 'DEPTH_UNLIKELY')
    #       occ.search(taxonKey: 1, issue: ['DEPTH_UNLIKELY','COORDINATE_ROUNDED'])
    #       # Show all records in the Arizona State Lichen Collection that cant be matched to the GBIF
    #       # backbone properly:
    #       occ.search(datasetKey: '84c0e1a0-f762-11e1-a439-00145eb45e9a', issue: ['TAXON_MATCH_nil','TAXON_MATCH_HIGHERRANK'])
    #
    #       # If you pass in an invalid polygon you get hopefully informative errors
    #       ### the WKT string is fine, but GBIF says bad polygon
    #       wkt = 'POLYGON((-178.59375 64.83258989321493,-165.9375 59.24622380205539,
    #       -147.3046875 59.065977905449806,-130.78125 51.04484764446178,-125.859375 36.70806354647625,
    #       -112.1484375 23.367471303759686,-105.1171875 16.093320185359257,-86.8359375 9.23767076398516,
    #       -82.96875 2.9485268155066175,-82.6171875 -14.812060061226388,-74.8828125 -18.849111862023985,
    #       -77.34375 -47.661687803329166,-84.375 -49.975955187343295,174.7265625 -50.649460483096114,
    #       179.296875 -42.19189902447192,-176.8359375 -35.634976650677295,176.8359375 -31.835565983656227,
    #       163.4765625 -6.528187613695323,152.578125 1.894796132058301,135.703125 4.702353722559447,
    #       127.96875 15.077427674847987,127.96875 23.689804541429606,139.921875 32.06861069132688,
    #       149.4140625 42.65416193033991,159.2578125 48.3160811030533,168.3984375 57.019804336633165,
    #       178.2421875 59.95776046458139,-179.6484375 61.16708631440347,-178.59375 64.83258989321493))'
    #       occ.search(geometry: wkt)
    #
    #       # Faceting
    #       ## return no occurrence records with limit: 0
    #       x = occ.search(facet: "country", limit: 0)
    #       x['facets']
    #
    #       ## also return occurrence records
    #       x = occ.search(facet: "establishmentMeans", limit: 10)
    #       x['facets']
    #       x['results']
    #
    #       ## multiple facet variables
    #       x = occ.search(facet: ["country", "basisOfRecord"], limit: 10)
    #       x['results']
    #       x['facets']
    #       x['facets']['country']
    #       x['facets']['basisOfRecord']
    #       x['facets']['basisOfRecord']['count']
    #
    #       ## set a minimum facet count
    #       x = occ.search(facet: "country", facetMincount: 30000000L, limit: 0)
    #       x['facets']
    #
    #       ## paging per each faceted variable
    #       ### do so by passing in variables like "country" + "_facetLimit" = "country_facetLimit"
    #       ### or "country" + "_facetOffset" = "country_facetOffset"
    #       x = occ.search(
    #         facet: ["country", "basisOfRecord", "hasCoordinate"],
    #         country_facetLimit: 3,
    #         basisOfRecord_facetLimit: 6,
    #         limit: 0
    #       )
    #       x['facets']
    #
    #       # requests package options
    #       ## There's an acceptable set of requests options (['timeout', 'cookies', 'auth',
    #       ## 'allow_redirects', 'proxies', 'verify', 'stream', 'cert']) you can pass
    #       ## in via **kwargs, e.g., set a timeout
    #       x = occ.search(timeout: 1)

    def self.search(taxonKey: nil, repatriated: nil,
        kingdomKey: nil, phylumKey: nil, classKey: nil, orderKey: nil,
        familyKey: nil, genusKey: nil, subgenusKey: nil, scientificName: nil,
        country: nil, publishingCountry: nil, hasCoordinate: nil, typeStatus: nil,
        recordNumber: nil, lastInterpreted: nil, continent: nil,
        geometry: nil, recordedBy: nil, basisOfRecord: nil, datasetKey: nil,
        eventDate: nil, catalogNumber: nil, year: nil, month: nil,
        decimalLatitude: nil, decimalLongitude: nil, elevation: nil,
        depth: nil, institutionCode: nil, collectionCode: nil,
        hasGeospatialIssue: nil, issue: nil, q: nil, spellCheck: nil, mediatype: nil,
        limit: 300, offset: 0, establishmentMeans: nil,
        facet: nil, facetMincount: nil, facetMultiselect: nil,
        verbose: nil, options: nil)

        arguments = { taxonKey: taxonKey, repatriated: repatriated,
             kingdomKey: kingdomKey, phylumKey: phylumKey, classKey: classKey,
             orderKey: orderKey, familyKey: familyKey, genusKey: genusKey,
             subgenusKey: subgenusKey, scientificName: scientificName,
             country: country, publishingCountry: publishingCountry,
             hasCoordinate: hasCoordinate, typeStatus: typeStatus,
             recordNumber: recordNumber, lastInterpreted: lastInterpreted,
             continent: continent, geometry: geometry, recordedBy: recordedBy,
             basisOfRecord: basisOfRecord, datasetKey: datasetKey, eventDate: eventDate,
             catalogNumber: catalogNumber, year: year, month: month,
             decimalLatitude: decimalLatitude, decimalLongitude: decimalLongitude,
             elevation: elevation, depth: depth, institutionCode: institutionCode,
             collectionCode: collectionCode, hasGeospatialIssue: hasGeospatialIssue,
             issue: issue, q: q, spellCheck: spellCheck, mediatype: mediatype,
             limit: limit, offset: offset, establishmentMeans: establishmentMeans,
             facetMincount: facetMincount, facet: facet,
             facetMultiselect: facetMultiselect}.tostrings
        opts = arguments.delete_if { |k, v| v.nil? }
        return Request.new('occurrence/search', opts, verbose, options).perform
    end

  end
end
