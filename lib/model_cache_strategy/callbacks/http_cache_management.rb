# require 'net/http'
require 'model_cache_strategy/workers/varnish_cache_expirations_worker'

module ModelCacheStrategy
  module Callbacks
    module HttpCacheManagement
      extend ActiveSupport::Concern

      module ClassMethods
        def expire_cached_resource(resource)
          class_eval do
            class_attribute :cached_resource_name

            self.send("cached_resource_name=", resource)

            after_create  :expire_cached_resource, :unless => :skip_http_callbacks
            after_update  :expire_cached_resource, :unless => :skip_http_callbacks
            after_destroy :expire_cached_resource, :unless => :skip_http_callbacks

            define_method :expire_cached_resource do
              # puts ">"*50 + "[HttpCacheManagement] cached_resource_name: #{cached_resource_name}, class: #{self.class}"
              ModelCacheStrategy.for(cached_resource_name).new(self).expire!
            end
          end
        end
      end
    end

  end
end

## For tests:
# stub_request(:ban, "http://localhost/").
#   with(:headers => {'X-Invalidates'=>'(categories($|.*\/c-1(\/|$)))|(categories($|.*\/sc-1(\/|$)))|(subjects($|.*\/1(\/|$)))|(subjects($|.*\/2(\/|$)))|(subjects($|.*\/3(\/|$)))|(subjects($|.*\/4(\/|$)))|(categories($|.*\/cc-1(\/|$)))|(categories($|.*\/scc-1(\/|$)))|(categories($|.*\/c-2(\/|$)))|(categories($|.*\/sc-2(\/|$)))|(categories($|.*\/cc-2(\/|$)))|(categories($|.*\/scc-2(\/|$)))|(subjects($|.*\/5(\/|$)))'})