require "model_cache_strategy/version"
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/numeric'
require 'logger'

module ModelCacheStrategy
  mattr_writer :configuration

  mattr_accessor :resource_strategies # Used in strategies registration
  self.resource_strategies = {}

  mattr_accessor :logger
  self.logger = ::Logger.new(STDOUT)


  def self.adapters
    ModelCacheStrategy.configuration.adapters || []
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.for(identifier = nil)
    resource_strategies.fetch(identifier) { ModelCacheStrategy::CacheStrategies::NoCacheStrategy }
  end

  def self.register_strategy_for(resource, klass)
      resource_strategies[resource] = klass
  end

  def self.resource_name_for_strategy(klass)
    resource_strategies.invert[klass]
  end

  def self.reset
    @configuration = Configuration.new
  end
end

require 'model_cache_strategy/configuration'
require 'model_cache_strategy/adapters'
require 'model_cache_strategy/callbacks'
require 'model_cache_strategy/cache_strategies'
require 'model_cache_strategy/adapters_proxy'
require 'model_cache_strategy/sns_client'
require 'model_cache_strategy/error'