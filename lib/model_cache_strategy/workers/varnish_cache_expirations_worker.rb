require 'sidekiq'

module ModelCacheStrategy
  module Workers
    class VarnishCacheExpirationsWorker
      include Sidekiq::Worker

      def perform(expiration_regex)
        adapter = ModelCacheStrategy::Adapters::Varnish.new
        adapter.call_varnish(expiration_regex)
      end
    end

  end
end