require "gbif/request"
require "gbif/utils"

module Gbif
    module Registry

        def self.getdata_networks(x, uuid, opts, verbose, options) #:nodoc:
            if x != 'all' and uuid.nil?
                stop('You must specify a uuid if data does not equal "all"')
            end
            if uuid.nil?
                url = 'network'
            else
                if x == 'all'
                    url = 'network/' + uuid
                else
                    url = 'network/' + uuid + '/' + x
                end
            end
            Request.new(url, opts, verbose, options).perform
            # return { meta: get_meta(res), data: parse_results(res, uuid) }
        end

        def self.getdata_nodes(x, uuid, opts, isocode, verbose, options) #:nodoc:
            if x != 'all' and uuid.nil?
                stop('You must specify a uuid if data does not equal "all"')
            end

            if uuid.nil?
                if x == 'all'
                    url = 'node'
                else
                    if !isocode.nil? and x == 'country'
                        url = 'node/country/' + isocode
                    else
                        url = 'node/' + x
                    end
                end
            else
                if x == 'all'
                    url = 'node/' + uuid
                else
                    url = 'node/' + uuid + '/' + x
                end
            end

            Request.new(url, opts, verbose, options).perform
            # return {'meta': get_meta(res), 'data': parse_results(res, uuid)}
        end

    end
end
