require "gbifrb/request"
require "gbifrb/utils"

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

        def self.getdata_orgs(x, uuid, opts, verbose, options) # :nodoc:
            nouuid = ['all', 'deleted', 'pending', 'nonPublishing']
            if !nouuid.include? x and uuid.nil?
                stop('You must specify a uuid if data does not equal "all" and data does not equal one of ' + nouuid.join(', '))
            end

            if uuid.nil?
                if x == 'all'
                    url = 'organization'
                else
                    url = 'organization/' + x
                end
            else
                if x == 'all'
                    url = 'organization/' + uuid
                else
                    url = 'organization/' + uuid + '/' + x
                end
            end

            Request.new(url, opts, verbose, options).perform
            # return {'meta': get_meta(res), 'data': parse_results(res, uuid)}
        end

        def self.getdata_installations(x, uuid, opts, verbose, options) # :nodoc:
            if !['all','deleted', 'nonPublishing'].include? x and uuid.nil?
                stop('You must specify a uuid if data does not equal all and data does not equal one of deleted or nonPublishing')
            end

            if uuid.nil?
                if x == 'all'
                    url = 'installation'
                else
                    url = 'installation/' + x
                end
            else
                if x == 'all'
                    url = 'installation/' + uuid
                else
                    url = 'installation/' + uuid + '/' + x
                end
            end

            Request.new(url, opts, verbose, options).perform
            # return {'meta': get_meta(res), 'data': parse_results(res, uuid)}
        end

        def self.getdata_dataset_metrics(x, verbose, options) # :nodoc:
            url = 'dataset/' + x + '/metrics'
            Request.new(url, {}, verbose, options).perform
        end

        def self.datasets_fetch(x, uuid, opts, verbose, options) # :nodoc:
            if !['all','deleted','duplicate','subDataset','withNoEndpoint'].include? x and uuid.nil?
                stop('You must specify a uuid if data does not equal all and data does not equal of deleted, duplicate, subDataset, or withNoEndpoint')
            end

            if uuid.nil?
                if x == 'all'
                    url = 'dataset'
                else
                    if !id.nil? and x == 'metadata'
                        url = 'dataset/metadata/' + id + '/document'
                    else
                        url = 'dataset/' + x
                    end
                end
            else
                if x == 'all'
                    url = 'dataset/' + uuid
                else
                    url = 'dataset/' + uuid + '/' + x
                end
            end

            Request.new(url, opts, verbose, options).perform
        end

    end
end
