require "gbif/version"
require "gbif/request"
require "gbif/Species"

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

# @!macro cursor_params
#   @param cursor [String] Cursor character string to do deep paging. Default is `nil`.
#       Pass in '*' to start deep paging. Any combination of query, filters and facets may be
#       used with deep paging cursors. While limit may be specified along with cursor, offset
#       and sample cannot be used. See
#       https://github.com/CrossRef/rest-api-doc/blob/master/rest_api.md#deep-paging-with-cursors
#   @param cursor_max [Fixnum] Max records to retrieve. Only used when cursor
#       param used. Because deep paging can result in continuous requests until all
#       are retrieved, use this parameter to set a maximum number of records. Of course,
#       if there are less records found than this value, you will get only those found.

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

# @!macro field_queries
#   @param [Hash<Object>] args Field queries, as named parameters.
#       See https://github.com/CrossRef/rest-api-doc/blob/master/rest_api.md#field-queries
#       Field query parameters mut be named, and must start with `query_`. Any dashes or
#       periods should be replaced with underscores.

##
# gbif - The top level module for using methods
# to access gbif APIs
#
# The following methods, matching the main Crossref API routes, are available:
# * `gbif.works` - Use the /works endpoint
# * `gbif.members` - Use the /members endpoint
# * `gbif.prefixes` - Use the /prefixes endpoint
# * `gbif.funders` - Use the /funders endpoint
# * `gbif.journals` - Use the /journals endpoint
# * `gbif.types` - Use the /types endpoint
# * `gbif.licenses` - Use the /licenses endpoint
#
# Additional methods
# * `gbif.agency` - test the registration agency for a DOI
# * `gbif.content_negotiation` - Conent negotiation
# * `gbif.citation_count` - Citation count
# * `gbif.csl_styles` - get CSL styles
#
# All routes return an array of hashes
# For example, if you want to inspect headers returned from the HTTP request,
# and parse the raw result in any way you wish.
#
# @see https://github.com/CrossRef/rest-api-doc/blob/master/rest_api.md for
# detailed description of the Crossref API
#
# What am I actually searching when using the Crossref search API?
#
# You are using the Crossref search API described at
# https://github.com/CrossRef/rest-api-doc/blob/master/rest_api.md.
# When you search with query terms, on Crossref servers they are not
# searching full text, or even abstracts of articles, but only what is
# available in the data that is returned to you. That is, they search
# article titles, authors, etc. For some discussion on this, see
# https://github.com/CrossRef/rest-api-doc/issues/101
#
# Rate limiting
# Crossref introduced rate limiting recently. The rate limits apparently vary,
# so we can't give a predictable rate limit. As of this writing, the rate
# limit is 50 requests per second. Look for the headers `X-Rate-Limit-Limit`
# and `X-Rate-Limit-Interval` in requests to see what the current rate
# limits are.

module Gbif
  extend Configuration

  define_setting :user_name
  define_setting :pwd
  define_setting :base_url, "https://api.gbif.org/v1"

end
