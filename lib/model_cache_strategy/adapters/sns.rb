module ModelCacheStrategy
  module Adapters
    class Sns < Base
      # attr_accessor :expiration_list, :sns_client, :topic_name
      attr_accessor :expiration_list
      attr_reader :configuration

      def self.type
        :sns
      end

      def initialize
        @configuration = ModelCacheStrategy.configuration
        self
      end

      def expire!
        yield self
        ModelCacheStrategy::Workers::SnsPublicationWorker.perform_async(expiration_list)
      end

      def set_expiration(name, ids = [])
        ids = Set.new(Array(ids))

        self.expiration_list ||= Hash.new { |h, k| h[k] = Set.new }
        self.expiration_list[name].merge(ids) unless ids.blank?
      end

      def call_sns(expiration_list)
        expiration_list.each do |(resource_name, ids)|
          # message = { resource_type: resource_name, resource_ids: ids.to_a, type: callback_type }
          message = { resource_type: resource_name, resource_ids: ids.to_a }

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