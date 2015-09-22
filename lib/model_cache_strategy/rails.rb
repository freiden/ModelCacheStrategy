require 'rails'

module ModelCacheStrategy
  class ModelCacheStrategyRailties < Rails::Railtie
    initializer 'activeservice.autoload', :before => :set_autoload_paths do |app|
      app.config.autoload_paths << "#{app.config.root}/app/model_cache_strategies"
    end

    initializer 'callbacks.inclusion' do
      # ActiveSupport.on_load(:active_record) do
      #   include ModelCacheStrategy::Callbacks::HttpCacheManagement
      #   include ModelCacheStrategy::Callbacks::ModelUpdatePublisher
      # end
    end

    initializer 'gem.logger' do
      ModelCacheStrategy.logger = Rails.logger
    end
  end
end