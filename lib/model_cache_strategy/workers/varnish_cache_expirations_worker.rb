require 'sidekiq'

module ModelCacheStrategy
  module Workers
    class VarnishCacheExpirationsWorker
      include Sidekiq::Worker

      sidekiq_options throttle: { threshold: 3, period: 1.second }

      def perform(expiration_regex, callback_type = nil, index)
        Rails.logger.debug ">"*50 + " Performing varnish_expiration (#{index}) for: #{expiration_regex}"
        adapter = ModelCacheStrategy::Adapters::Varnish.new
        adapter.expire_cache!(expiration_regex, callback_type: callback_type)
      end
    end

  end
end