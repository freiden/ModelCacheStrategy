module ModelCacheStrategy
  module Adapters
    class Sns < Base
      # attr_accessor :expiration_list, :sns_client, :topic_name
      attr_accessor :expiration_list
      attr_reader :configuration

      # def initialize(topic_name)
      #   @sns_client = SnsClient.new(topic_name)
      # end

      def initialize
        @configuration = ModelCacheStrategy.configuration
        self
      end

      def expire
        yield self
        settings = { topic_name: topic_name }
        SnsPublicationWorker.perform_async(expiration_list, settings)
      end

      def set_expiration(name, ids = [])
        ids = Set.new(ids)
        self.expiration_list ||= Hash.new { |h, k| h[k] = Set.new }
        self.expiration_list[name].merge(ids) unless ids.blank?
      end

      def call_sns(expiration_list, callback_type = nil)
        expiration_list.each do |(resource_name, ids)|
          message = { resource_type: resource_name, resource_ids: ids.to_a, type: callback_type }

          sns_client.publish(message)
        end
      end
    end
  end
end