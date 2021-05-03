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
# Gbif::Species
#
# Class to perform HTTP requests to the GBIF API
# @!macro gbif_params
#   @param offset [Fixnum] Number of record to start at, any non-negative integer. Default: 0
#   @param limit [Fixnum] Number of results to return. Default: 100
#   @param verbose [Boolean] Print request headers to stdout. Default: false
module Gbif
  module Species
    ##
    # Search the GBIF taxonomic backbone
    #
    # @!macro gbif_params
    # @!macro gbif_options
    # @param name [String] Full scientific name potentially with authorship (required)
    # @param rank [String] The rank given as our rank enum. (optional)
    # @param kingdom [String] If provided default matching will also try to match against this
    #   if no direct match is found for the name alone. (optional)
    # @param phylum [String] If provided default matching will also try to match against this
    #   if no direct match is found for the name alone. (optional)
    # @param clazz [String] If provided default matching will also try to match against this
    #   if no direct match is found for the name alone. (optional)
    # @param order [String] If provided default matching will also try to match against this
    #   if no direct match is found for the name alone. (optional)
    # @param family [String] If provided default matching will also try to match against this
    #   if no direct match is found for the name alone. (optional)
    # @param genus [String] If provided default matching will also try to match against this
    #   if no direct match is found for the name alone. (optional)
    # @param strict [bool] If True it (fuzzy) matches only the given name, but never a
    #   taxon in the upper classification (optional)
    # @return [Hash] A hash
    #
    # @example
    #      require 'gbifrb'
    #
    #      species = Gbif::Species
    #      species.name_backbone(name: "Helianthus")
    #      species.name_backbone(name: "Poa")
    def self.name_backbone(name:, rank: nil, kingdom: nil, phylum: nil,
      clazz: nil, order: nil, family: nil, genus: nil, strict: nil,
      offset: nil, limit: nil, verbose: nil, options: nil)

      arguments = { name: name, rank: rank, kingdom: kingdom,
              phylum: phylum, class: clazz, order: order,
              family: family, genus: genus, strict: strict,
              offset: offset, limit: limit }.tostrings
      opts = arguments.delete_if { |k, v| v.nil? }
      Request.new("species/match", opts, verbose, options).perform
    end

    ##
    # Search the GBIF suggester
    #
    # @!macro gbif_params
    # @!macro gbif_options
    # @param q [String] Simple search parameter. The value for this parameter can be a
    #   simple word or a phrase. Wildcards can be added to the simple word parameters only,
    #   e.g. 'q=*puma*' (Required)
    # @param datasetKey [String] Filters by the checklist dataset key (a uuid, see examples)
    # @param rank [String] A taxonomic rank. One of 'class', 'cultivar', 'cultivar_group', 'domain', 'family',
    #   'form', 'genus', 'informal', 'infrageneric_name', 'infraorder', 'infraspecific_name',
    #   'infrasubspecific_name', 'kingdom', 'order', 'phylum', 'section', 'series', 'species', 'strain', 'subclass',
    #   'subfamily', 'subform', 'subgenus', 'subkingdom', 'suborder', 'subphylum', 'subsection', 'subseries',
    #   'subspecies', 'subtribe', 'subvariety', 'superclass', 'superfamily', 'superorder', 'superphylum',
    #   'suprageneric_name', 'tribe', 'unranked', or 'variety'.
    # @return [Hash] A hash
    #
    # @example
    #      require 'gbifrb'
    #
    #      species = Gbif::Species
    #      species.name_suggest(q: "Helianthus")
    #      species.name_suggest(q: "Poa")
    def self.name_suggest(q: nil, datasetKey: nil, rank: nil, limit: 100, offset: nil,
      verbose: nil, options: nil)

      arguments = { q: q, datasetKey: datasetKey, rank: rank,
        limit: limit, offset: offset }.tostrings
      opts = arguments.delete_if { |k, v| v.nil? }
      Request.new("species/suggest", opts, verbose, options).perform
    end

    ##
    # Search for GBIF name usages
    #
    # @!macro gbif_params
    # @!macro gbif_options
    # @param name [String] Filters by a case insensitive, canonical namestring,
    #   e.g. 'Puma concolor'
    # @param language [String] Language, default is english
    # @param datasetKey [String] Filters by the dataset's key (a uuid)
    # @param sourceId [Fixnum] Filters by the source identifier.
    # @return [Array] An array of hashes
    #
    # @example
    #      require 'gbifrb'
    #
    #      speices = Gbif::Species
    #      speices.name_usage(name: "Helianthus")
    #      speices.name_usage(name: "Poa")
    def self.name_usage(name: nil, language: nil, datasetKey: nil, sourceId: nil,
      limit: 100, offset: nil, verbose: nil, options: nil)

      arguments = { name: name, language: language, datasetKey: datasetKey, sourceId: sourceId,
        limit: limit, offset: offset }.tostrings
      opts = arguments.delete_if { |k, v| v.nil? }
      Request.new("species/", opts, verbose, options).perform
    end

    ##
    # Search the GBIF full text
    #
    # @param q [String] Query term(s) for full text search (optional)
    # @param rank [String] 'CLASS', 'CULTIVAR', 'CULTIVAR_GROUP', 'DOMAIN', 'FAMILY',
    #   'FORM', 'GENUS', 'INFORMAL', 'INFRAGENERIC_NAME', 'INFRAORDER', 'INFRASPECIFIC_NAME',
    #   'INFRASUBSPECIFIC_NAME', 'KINGDOM', 'ORDER', 'PHYLUM', 'SECTION', 'SERIES', 'SPECIES', 'STRAIN', 'SUBCLASS',
    #   'SUBFAMILY', 'SUBFORM', 'SUBGENUS', 'SUBKINGDOM', 'SUBORDER', 'SUBPHYLUM', 'SUBSECTION', 'SUBSERIES',
    #   'SUBSPECIES', 'SUBTRIBE', 'SUBVARIETY', 'SUPERCLASS', 'SUPERFAMILY', 'SUPERORDER', 'SUPERPHYLUM',
    #   'SUPRAGENERIC_NAME', 'TRIBE', 'UNRANKED', 'VARIETY' (optional)
    # @param verbosity [bool] If True show alternative matches considered which had been rejected.
    # @param higherTaxonKey [String] Filters by any of the higher Linnean rank keys. Note this
    #    is within the respective checklist and not searching nub keys across all checklists (optional)
    # @param status [String] (optional) Filters by the taxonomic status as one of:
    #  * 'ACCEPTED'
    #  * 'DETERMINATION_SYNONYM' Used for unknown child taxa referred to via spec, ssp, ...
    #  * 'DOUBTFUL' Treated as accepted, but doubtful whether this is correct.
    #  * 'HETEROTYPIC_SYNONYM' More specific subclass of 'SYNONYM'.
    #  * 'HOMOTYPIC_SYNONYM' More specific subclass of 'SYNONYM'.
    #  * 'INTERMEDIATE_RANK_SYNONYM' Used in nub only.
    #  * 'MISAPPLIED' More specific subclass of 'SYNONYM'.
    #  * 'PROPARTE_SYNONYM' More specific subclass of 'SYNONYM'.
    #  * 'SYNONYM' A general synonym, the exact type is unknown.
    # @param isExtinct [bool] Filters by extinction status (e.g. 'isExtinct=True')
    # @param habitat [String] Filters by habitat. One of: 'marine', 'freshwater', or
    #    'terrestrial' (optional)
    # @param nameType [String] (optional) Filters by the name type as one of:
    #  * 'BLACKLISTED' surely not a scientific name.
    #  * 'CANDIDATUS' Candidatus is a component of the taxonomic name for a bacterium that cannot be maintained in a Bacteriology Culture Collection.
    #  * 'CULTIVAR' a cultivated plant name.
    #  * 'DOUBTFUL' doubtful whether this is a scientific name at all.
    #  * 'HYBRID' a hybrid formula (not a hybrid name).
    #  * 'INFORMAL' a scientific name with some informal addition like "cf." or indetermined like Abies spec.
    #  * 'SCINAME' a scientific name which is not well formed.
    #  * 'VIRUS' a virus name.
    #  * 'WELLFORMED' a well formed scientific name according to present nomenclatural rules.
    # @param datasetKey [String] Filters by the dataset's key (a uuid) (optional)
    # @param nomenclaturalStatus [String] Not yet implemented, but will eventually allow for
    #    filtering by a nomenclatural status enum
    # @param facet [String] A list of facet names used to retrieve the 100 most frequent values
    #    for a field. Allowed facets are: 'datasetKey', 'higherTaxonKey', 'rank', 'status',
    #    'isExtinct', 'habitat', and 'nameType'. Additionally 'threat' and 'nomenclaturalStatus'
    #    are legal values but not yet implemented, so data will not yet be returned for them. (optional)
    # @param facetMincount [String] Used in combination with the facet parameter. Set
    #    'facetMincount={#}' to exclude facets with a count less than {#}, e.g.
    #    http://bit.ly/1bMdByP only shows the type value 'ACCEPTED' because the other
    #    statuses have counts less than 7,000,000 (optional)
    # @param facetMultiselect [bool] Used in combination with the facet parameter. Set
    #    'facetMultiselect=True' to still return counts for values that are not currently
    #    filtered, e.g. http://bit.ly/19YLXPO still shows all status values even though
    #    status is being filtered by 'status=ACCEPTED' (optional)
    # @param type [String] Type of name. One of 'occurrence', 'checklist', or 'metadata'. (optional)
    # @param hl [bool] Set 'hl=True' to highlight terms matching the query when in fulltext
    #    search fields. The highlight will be an emphasis tag of class 'gbifH1' e.g.
    #    'q='plant', hl=True'. Fulltext search fields include: 'title', 'keyword', 'country',
    #    'publishing country', 'publishing organization title', 'hosting organization title', and
    #    'description'. One additional full text field is searched which includes information from
    #    metadata documents, but the text of this field is not returned in the response. (optional)
    # @!macro gbif_params
    # @!macro gbif_options
    # @return [Hash] A hash
    #
    # @example
    #      require 'gbifrb'
    #
    #      speices = Gbif::Species
    #      speices.name_lookup(q: "Helianthus")
    #      speices.name_lookup(q: "Poa")
    def self.name_lookup(q: nil, rank: nil, higherTaxonKey: nil, status: nil,
      isExtinct: nil, habitat: nil, nameType: nil, datasetKey: nil,
      nomenclaturalStatus: nil, limit: 100, offset: nil, facet: false,
      facetMincount: nil, facetMultiselect: nil, type: nil, hl: false,
      verbosity: false, verbose: nil, options: nil)

      arguments = { q: q, rank: rank, higherTaxonKey: higherTaxonKey,
        status: status, isExtinct: isExtinct, habitat: habitat, nameType: nameType,
        datasetKey: datasetKey, nomenclaturalStatus: nomenclaturalStatus,
        limit: limit, offset: offset, facet: facet, facetMincount: facetMincount,
        facetMultiselect: facetMultiselect, type: type, hl: hl,
        verbose: verbosity }.tostrings
      opts = arguments.delete_if { |k, v| v.nil? }
      Request.new("species/search", opts, verbose, options).perform
    end

  end
end
