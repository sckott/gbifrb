##
# Gbif::Response
#
# Class to give back response
module Gbif
  class Response #:nodoc:
    attr_reader :ids, :response

    def initialize(ids, res)
      @ids = ids
      @res = res
    end

    def raw_body
      # @res
      @res.collect { |x| x.body }
    end

    def parsed
      # JSON.parse(@res.body)
      @res.collect { |x| JSON.parse(x.body) }
    end

    def links
      # @res['message']['link']
      @res.collect { |x| x['message']['link'] }
    end

    def pdf
      tmp = links
      if !tmp.nil?
        tmp.collect { |z|
          z.select{ |x| x['content-type'] == "application/pdf" }[0]['URL']
        }
      end
    end

  end
end
