require 'active_support/concern'

# require 'model_cache_strategy/callbacks/http_cache_management'
# require 'model_cache_strategy/callbacks/model_update_publisher'
require 'model_cache_strategy/callbacks/cache_management'

if defined? ActiveRecord
  # ActiveRecord::Base.include ModelCacheStrategy::Callbacks::HttpCacheManagement
  # ActiveRecord::Base.include ModelCacheStrategy::Callbacks::ModelUpdatePublisher
  ActiveRecord::Base.include ModelCacheStrategy::Callbacks::CacheManagement
end