require 'net/http'
require 'model_cache_strategy/workers/varnish_cache_expirations_worker'

module ModelCacheStrategy
  module Adapters
    class Varnish < Base
      attr_accessor :expiration_regexp


      ############################################### Constants ###############################################

      SLICE_SIZE = 50


      ############################################# Class methods #############################################

      def self.type
        :varnish
      end


      ############################################# Instance methods #############################################

      def cache_control(cache_max_age = nil)
        cache_max_age ||= ModelCacheStrategy.configuration.varnish[:cache_max_age]
        ['Cache-Control', "max-age=#{cache_max_age}, public"]
      end

      def expire!(callback_type = nil)
        yield self

        # puts ">"*50 + " expiration_regexp size: #{expiration_regexp.size}"
        Array(expiration_regexp).uniq.each_with_index do |expiration_regex, index|
          ModelCacheStrategy::Workers::VarnishCacheExpirationsWorker.perform_async(expiration_regex, callback_type, index)
        end
        reset!
      end

      def expire_cache!(expiration_regex, callback_type: nil)
        hosts_ips = ModelCacheStrategy.configuration.varnish[:hosts_ips]
        varnish_port = ModelCacheStrategy.configuration.varnish[:varnish_port]

        hosts_ips.each do |host_ip|
          call_varnish(host_ip: host_ip, varnish_port: varnish_port, expiration_regex: expiration_regex, callback_type: callback_type)
        end
      end

      def reset!
        self.expiration_regexp = []
      end

      def set_expiration(name, ids = [])
        ids = Array(ids).uniq.sort
        self.expiration_regexp ||= []
        set_expiration_regex(name, ids) unless ids.blank?
      end

      def set_global_expiration(resources_to_expire, ids = nil)
        self.expiration_regexp = resources_to_expire.is_a?(Array) ? resources_to_expire.join('|') : %w('.*')
      end

      def type
        # :varnish
        self.class.type
      end


    private

      def call_varnish(host_ip:, varnish_port:, expiration_regex:, callback_type:)
        http = Net::HTTP.new(host_ip, varnish_port)
        request = Ban.new("/")
        request.initialize_http_header({ 'X-Invalidates' => expiration_regex })
        response = http.request(request)
        Rails.logger.debug "[BAN RESPONSE] expiration_regex: #{expiration_regex} - response: #{response.inspect}"
        response
      rescue StandardError => se
        Rails.logger.error "Banning failed due to: \n" + se.message
        Rails.logger.error se.backtrace
      end

      def generate_expiration_regex(name, ids)
        ids_regexes = ids.map { |id| "/#{id}(/|$)" }
        "(#{name}($|(.*)(#{ids_regexes.join('|')})))".gsub('/','\/')
      end

      def set_expiration_regex(name, ids)
        # WARN: Format of regex generated: (subjects($|(.*)(\/1(\/|$)|\/2(\/|$)|\/3(\/|$))))
        ## for each element id: '\/1(\/|$)', easily readable!! :)
        ids.sort.each_slice(SLICE_SIZE) do |slice_ids|
          self.expiration_regexp << generate_expiration_regex(name, slice_ids)
        end
      end

    end
  end
end
