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

      def enabled?
        result = %x(pidof varnishd).present?
        puts "WARNING: Varnish is disabled on this system, baning request will not be sent!" unless result
        result
      end

      def expire!(callback_type = nil)
        yield self

        ModelCacheStrategy::Workers::VarnishCacheExpirationsWorker.perform_async(expiration_regexp.uniq, callback_type)
      end

      def expire_cache!(regex_array, callback_type: nil)
        hosts_ips = ModelCacheStrategy.configuration.varnish[:hosts_ips]
        varnish_port = ModelCacheStrategy.configuration.varnish[:varnish_port]
        regex_array.each do |varnish_regex|
          hosts_ips.each do |host_ip|
            call_varnish(host_ip: host_ip, varnish_port: varnish_port, banning_key: varnish_regex, callback_type: callback_type)
          end
        end
      end

      def set_expiration(name, ids = [])
        ids = Array(ids)
        self.expiration_regexp ||= []
        generate_expiration_regex(name, ids) unless ids.blank?
      end

      def set_global_expiration(name, _)
        self.expiration_regexp = %w('.*')
      end

      def type
        # :varnish
        self.class.type
      end


    private

      def generate_expiration_regex(name, ids)
        # "(#{name}($|.*/#{ids.join('/')}(/|$)))".gsub('/', '\/')
        ids.each_slice(SLICE_SIZE) do |slice_ids|
          self.expiration_regexp << "(#{name}($|.*/#{slice_ids.join('/')}(/|$)))".gsub('/', '\/')
        end
      end

      def call_varnish(host_ip:, varnish_port:, banning_key:, callback_type:)
        http = Net::HTTP.new(host_ip, varnish_port)
        request = Ban.new("/")
        request.initialize_http_header({ 'X-Invalidates' => banning_key })
        response = http.request(request)
        Rails.logger.debug ">"*50 + " BAN RESPONSE: " + response.inspect
        response
      rescue StandardError => se
        Rails.logger.error "Banning failed due to: \n" + se.message
        Rails.logger.error se.backtrace
      end

    end
  end
end
