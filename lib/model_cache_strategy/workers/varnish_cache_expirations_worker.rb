require 'sidekiq'

module ModelCacheStrategy
  module Workers
    class VarnishCacheExpirationsWorker
      include Sidekiq::Worker

      # sidekiq_options throttle: { threshold: 3, period: 1.second }, queue: :varnish_expiration
      sidekiq_options :queue => :varnish_expiration,  throttle: { #threshold: Proc.new { 3 }, period: Proc.new { 1.second } }
        threshold: Proc.new { ModelCacheStrategy.configuration.varnish[:worker_throttling][:threshold] },
        period:    Proc.new { ModelCacheStrategy.configuration.varnish[:worker_throttling][:period] }
      }




      def perform(expiration_regex, callback_type = nil, index)
        Rails.logger.debug "[#{DateTime.now.to_s}][VarnishCacheExpirationsWorker] Performing expiration (#{index}) for: #{expiration_regex}"
        adapter = ModelCacheStrategy::Adapters::Varnish.new
        adapter.expire_cache!(expiration_regex, callback_type: callback_type)
      end
    end

  end
end