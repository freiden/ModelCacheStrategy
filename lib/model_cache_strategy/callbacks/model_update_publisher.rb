# require 'net/http'
require 'model_cache_strategy/workers/sns_publication_worker'

module ModelCacheStrategy
  module Callbacks
    module ModelUpdatePublisher
      extend ActiveSupport::Concern

      module ClassMethods
        def publish_model_notification(resource)
          class_eval do
            class_attribute :cached_resource_name

            self.send('cached_resource_name=', resource)

            after_create  -> { publish_model_notification(:create) }, :unless => :skip_http_callbacks
            after_update  -> { publish_model_notification(:update) }, :unless => :skip_http_callbacks
            after_destroy -> { publish_model_notification(:delete) }, :unless => :skip_http_callbacks


            define_method :publish_model_notification do |callback_type|
              ModelCacheStrategy.for(cached_resource_name).new(self).expire!
            end
          end
        end
      end
    end

  end
end