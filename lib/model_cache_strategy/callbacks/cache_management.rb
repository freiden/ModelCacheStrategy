# require 'model_cache_strategy/workers/sns_publication_worker'

module ModelCacheStrategy
  module Callbacks
    module CacheManagement
      extend ActiveSupport::Concern

      module ClassMethods
        def resource_hook(resource, **options)
          class_eval do
            class_attribute :cached_resource_name

            self.send('cached_resource_name=', resource)

            after_create  -> { resource_hook(:create) }, options
            after_update  -> { resource_hook(:update) }, options
            after_destroy -> { resource_hook(:delete) }, options

            define_method :resource_hook do |callback_type|
              # puts ">"*50 + " callback_type: #{callback_type} - It works!!"
              ModelCacheStrategy.for(cached_resource_name).new(self, callback_type: callback_type).expire!
            end
          end
        end
      end

    end
  end
end