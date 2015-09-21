module ModelCacheStrategy
  module CacheStrategies
    class NoCacheStrategy
      def self.cache_key
        nil
      end

      def self.custom_cache_header(ids = nil)
        []
      end

      def self.cache_control
        ['Cache-Control', 'private, no-cache']
      end

      def self.generate_cache_key(ids = nil)
        return cache_key if ids.blank?

        ids = Array(ids)
        "#{cache_key}/#{ids.join('/')}"
      end

      def adapters
        ModelCacheStrategy.configuration.adapters
      end

      def initialize(resource = nil)
      end


    protected

      def expire_cache
        return nil
      end
    end

  end
end
