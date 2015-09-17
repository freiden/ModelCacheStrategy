require 'rails'

module ModelCacheStrategy
  class ModelCacheStrategyRailties < Rails::Railtie
    initializer 'activeservice.autoload', :before => :set_autoload_paths do |app|
      app.config.autoload_paths << "#{app.config.root}/app/model_cache_strategies"
    end
  end
end