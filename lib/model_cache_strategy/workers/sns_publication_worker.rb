require 'sidekiq'

module ModelCacheStrategy
  module Workers
    class SnsPublicationWorker
      include Sidekiq::Worker

      def perform(expiration_list, callback_type = nil)
        adapter = ModelCacheStrategy::Adapters::Sns.new
        adapter.call_sns(expiration_list, callback_type: callback_type)
      end
    end

  end
end