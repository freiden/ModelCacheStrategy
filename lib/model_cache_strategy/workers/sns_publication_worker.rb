module ModelCacheStrategy
  module Workers
    class SnsPublicationWorker
      include Sidekiq::Worker

      def perform(expiration_list)
        adapter = ModelCacheStrategy::Adapters::Sns.new
        adapter.call_sns(expiration_list)
      end
    end

  end
end