module ModelCacheStrategy
  module CacheStrategies
    class DefaultCacheStrategy
      attr_accessor :resource

      #################################################### Class methods ###################################################

      def self.cache_key
        ModelCacheStrategy.resource_name_for_strategy(self)
      end

      def self.custom_cache_header(ids = nil)
        [last_http_adapter.custom_cache_header, generate_cache_key(ids)]
      end

      def self.cache_control
        last_http_adapter.cache_control
      end

      def self.generate_cache_key(ids = nil)
        return cache_key.to_s if ids.blank?

        ids = Array(ids).sort.uniq
        "#{cache_key}/#{ids.join('/')}"
      end


      ################################################## Instance methods ##################################################

      def adapters
        ModelCacheStrategy.configuration.adapters
      end

      def initialize(resource = nil)
        @resource = resource
      end

      def expire
        return unless adapters.enabled?
        expire_cache
      end


    protected

      def expire_cache
        raise "TBD in each strategy"
      end

      def last_http_adapter
        adapters.by_type(:http).last # Deliberately choosing the last Http Adapters
      end
    end

  end
end
