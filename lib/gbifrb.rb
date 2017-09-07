require "gbifrb/version"
require "gbifrb/request"
require "gbifrb/Species"
require "gbifrb/Registry"
require "gbifrb/Occurrences"

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

##
# gbif - The top level module for using methods to access the GBIF API

module Gbif
  extend Configuration

  define_setting :user_name
  define_setting :pwd
  define_setting :base_url, "https://api.gbif.org/v1"

end
