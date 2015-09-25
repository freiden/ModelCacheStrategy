require 'model_cache_strategy/workers/sns_publication_worker'

module ModelCacheStrategy
  module Adapters
    class Sns < Base
      attr_accessor :expiration_list
      attr_reader :configuration

      def self.type
        :sns
      end

      def initialize
        @configuration = ModelCacheStrategy.configuration
        self
      end

      def expire!(callback_type = nil)
        yield self
        ModelCacheStrategy::Workers::SnsPublicationWorker.perform_async(expiration_list, callback_type)
      end

      def set_expiration(name, ids = [])
        ids = Set.new(Array(ids))

        self.expiration_list ||= Hash.new { |h, k| h[k] = Set.new }
        self.expiration_list[name].merge(ids) unless ids.blank?
      end

      def set_global_expiration(name, ids)
        set_expiration(name, ids)
      end

      def call_sns(expiration_list, callback_type: nil)
        expiration_list.each do |(resource_name, ids)|
          message = { resource_kind: resource_name, resource_ids: ids.to_a, type: callback_type }
          configuration.sns_client.publish(configuration.sns[:topic_name], message)
        end
      end

      def type
        # :sns
        self.class.type
      end

    end
  end
end