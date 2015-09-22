module ModelCacheStrategy
  module CacheStrategies
    class DefaultCacheStrategy
      class_attribute :used_adapters

      attr_accessor :resource
      attr_reader :callback_type

      #################################################### Class methods ###################################################

      def self.cache_key
        ModelCacheStrategy.resource_name_for_strategy(self)
      end

      def self.custom_cache_header(ids = nil)
        if get_varnish_adapter.present?
          [get_varnish_adapter.custom_cache_header, generate_cache_key(ids)]
        else
          ModelCacheStrategy.logger.warn "No Varnish adapter defined on this strategy: #{self} - Custom Cache Header not available."
          ModelCacheStrategy::CacheStrategies::NoCacheStrategy.custom_cache_header
        end
      end

      def self.cache_control
        if get_varnish_adapter.present?
          get_varnish_adapter.cache_control
        else
          ModelCacheStrategy.logger.warn "No Varnish adapter defined on this strategy: #{self} - Cache-Control not available."
          ModelCacheStrategy::CacheStrategies::NoCacheStrategy.cache_control
        end
      end

      def self.generate_cache_key(ids = nil)
        return cache_key.to_s if ids.blank?

        ids = Array(ids).sort.uniq
        "#{cache_key}/#{ids.join('/')}"
      end

      def self.use_adapter_for(adapter_name, on: [:create, :update, :delete], **options)
        adapter_setting = {}
        adapter_setting[adapter_name.to_sym] = options.merge({ on: Array(on) })

        self.used_adapters ||= {}
        self.used_adapters.merge!(adapter_setting)
      end

      def self.adapters
        get_current_adapters
      end

      def self.get_current_adapters
        @get_current_adapters ||= begin
          _adapters = ModelCacheStrategy.configuration.adapters
          _adapters.by_type(used_adapters.keys)
        end
      end

      def self.get_varnish_adapter
        get_current_adapters.by_type(ModelCacheStrategy::Adapters::Varnish.type).try(:last)
      end


      ################################################## Instance methods ##################################################

      def adapters
        # ModelCacheStrategy.configuration.adapters
        get_current_adapters
      end

      def initialize(resource = nil, callback_type: nil)
        @resource = resource
        @callback_type = callback_type
      end

      def expire!
        return unless adapters.enabled?
        expire_cache
      end


    protected

      def expire_cache
        raise "TBD in each strategy"
      end

      def get_current_adapters
        @get_current_adapters ||= begin
          _adapters = self.class.get_current_adapters #ModelCacheStrategy.configuration.adapters
          _adapters.by_type(filtered_used_adapters.keys)
        end
      end

      def filtered_used_adapters
        used_adapters.select do |adapter_name, settings|
          settings[:on].include?(callback_type)
        end
      end

      def get_current_topic_name
        (filtered_used_adapters[:sns] || {})[:topic_name]
      end

      def get_current_cache_max_age
        (filtered_used_adapters[:varnish] || {})[:cache_max_age]
      end

    end

  end
end
