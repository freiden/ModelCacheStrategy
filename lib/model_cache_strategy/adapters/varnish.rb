require 'net/http'
require 'model_cache_strategy/workers/varnish_cache_expirations_worker'

module ModelCacheStrategy
  module Adapters
    class Varnish < Base
      attr_accessor :expiration_regexp

      def self.type
        :varnish
      end

      def cache_control
        ['Cache-Control', "max-age=#{cache_max_age}, public"]
      end

      def expire!(callback_type = nil)
        yield self
        ModelCacheStrategy::Workers::VarnishCacheExpirationsWorker.perform_async(expiration_regexp.uniq, callback_type)
      end

      def set_expiration(name, ids = [])
        ids = Array(ids)
        self.expiration_regexp ||= []
        self.expiration_regexp << generate_expiration_regex(name, ids) unless ids.blank?
      end

      def call_varnish(regex_array, callback_type: nil)
        banning_key = regex_array.join('|')

        uri = URI.parse(ModelCacheStrategy.configuration.varnish[:host])
        http = Net::HTTP.new(uri.host, uri.port)
        request = Ban.new(uri.request_uri)
        request.initialize_http_header({ 'X-Invalidates' => banning_key })
        response = http.request(request)
        Rails.logger.debug ">"*50 + " BAN RESPONSE: " + response.inspect
        response
      rescue Exception => e
        Rails.logger.error "Banning failed due to: \n" + e.message
        Rails.logger.error e.backtrace
      end

      def enabled?
        result = %x(pidof varnishd).present?
        puts "WARNING: Varnish is disabled on this system, baning request will not be sent!" unless result
        result
      end

      def type
        # :varnish
        self.class.type
      end

    private

      def generate_expiration_regex(name, ids)
        "(#{name}($|.*/#{ids.join('/')}(/|$)))".gsub('/', '\/')
      end
    end
  end
end