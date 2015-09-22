# require 'model_cache_strategy/workers/sns_publication_worker'

module ModelCacheStrategy
  module Callbacks
    module CacheManagement
      extend ActiveSupport::Concern

      module ClassMethods
        def hook_resource(resource)
          class_eval do
            class_attribute :cached_resource_name

            self.send('cached_resource_name=', resource)

            after_create  -> { hook_resource(:create) }, :unless => :skip_http_callbacks
            after_update  -> { hook_resource(:update) }, :unless => :skip_http_callbacks
            after_destroy -> { hook_resource(:delete) }, :unless => :skip_http_callbacks

            define_method :hook_resource do |callback_type|
              ModelCacheStrategy.for(cached_resource_name).new(self, callback_type: callback_type).expire!
            end
          end
        end
      end

    end
  end
end