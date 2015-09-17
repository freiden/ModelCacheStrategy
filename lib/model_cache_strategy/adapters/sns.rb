module ModelCacheStrategy
  module Adapters
    class Sns < Base
      attr_accessor :expiration_list, :sns_client, :topic_name

      def initialize(topic_name = DEFAULT_TOPIC_NAME)
        @sns_client = SnsClient.new(topic_name) # TODO: use get_sns_client method!!!
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

    private

      def get_sns_client
        # .... TODO!!
      end
    end
  end
end