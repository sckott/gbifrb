require "faraday"
require "multi_json"
require "gbifrb/error"
require "gbifrb/constants"
require 'gbifrb/utils'
require 'gbifrb/helpers/configuration'

##
# Gbif::Request
#
# Class to perform HTTP requests to the Crossref API
module Gbif
  class Request #:nodoc:

    attr_accessor :endpt
    attr_accessor :args
    attr_accessor :verbose
    attr_accessor :options

    def initialize(endpt, args, verbose, options)
      self.endpt = endpt
      self.args = args
      self.verbose = verbose
      self.options = options
    end

    def perform
      if verbose
        conn = Faraday.new(:url => Gbif.base_url, :request => self.options || []) do |f|
          f.response :logger
          f.adapter  Faraday.default_adapter
          f.use FaradayMiddleware::RaiseHttpException
        end
      else
        conn = Faraday.new(:url => Gbif.base_url, :request => self.options || []) do |f|
          f.adapter  Faraday.default_adapter
          f.use FaradayMiddleware::RaiseHttpException
        end
      end

      conn.headers[:user_agent] = make_ua
      conn.headers["X-USER-AGENT"] = make_ua

      res = conn.get self.endpt, self.args
      return MultiJson.load(res.body)
    end

  end
end
