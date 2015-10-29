require 'sidekiq'

module ModelCacheStrategy
  module Workers
    class VarnishCacheExpirationsWorker
      include Sidekiq::Worker

      # sidekiq_options throttle: { threshold: 3, period: 1.second }, queue: :varnish_expiration
      sidekiq_options throttle: -> { ModelCacheStrategy.configuration.varnish[:worker_throttling] },
        queue: :varnish_expiration

      def perform(expiration_regex, callback_type = nil, index)
        Rails.logger.debug "[VarnishCacheExpirationsWorker] Performing expiration (#{index}) for: #{expiration_regex}"
        adapter = ModelCacheStrategy::Adapters::Varnish.new
        adapter.expire_cache!(expiration_regex, callback_type: callback_type)
      end
    end

  end
end