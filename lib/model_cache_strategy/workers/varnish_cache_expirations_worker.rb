require 'sidekiq'

module ModelCacheStrategy
  module Workers
    class VarnishCacheExpirationsWorker
      include Sidekiq::Worker

      # TODO: Remove those settings unless throttling considered useful again!!
      # sidekiq_options :queue => :varnish_expiration,  throttle: {
      #   threshold: Proc.new { ModelCacheStrategy.configuration.varnish[:worker_throttling][:threshold] },
      #   period:    Proc.new { ModelCacheStrategy.configuration.varnish[:worker_throttling][:period] }
      # }

      sidekiq_options :queue => :varnish_expiration



      def perform(expiration_regex, callback_type = nil, index)
        Rails.logger.debug "[#{DateTime.now.to_s}][VarnishCacheExpirationsWorker] Performing expiration (#{index}) for: #{expiration_regex}"
        adapter = ModelCacheStrategy::Adapters::Varnish.new
        adapter.expire_cache!(expiration_regex, callback_type: callback_type)
      end
    end

  end
end