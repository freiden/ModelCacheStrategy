require "model_cache_strategy/version"

module ModelCacheStrategy
  mattr_accessor :resource_strategies # Used in strategies registration

  self.resource_strategies = {}

  def self.adapters=(adapters)
    @adapters = AdaptersProxy.new(adapters)
  end

  def self.adapters
    @adapters || []
  end

  def self.for(identifier = nil)
    resource_strategies.fetch(identifier) { NoCacheStrategy }
  end

  def self.register_strategy_for(resource, klass)
      resource_strategies[resource] = klass
  end

  def self.resource_name_for_strategy(klass)
    resource_strategies.invert[klass]
  end
end

require 'model_cache_strategy/adapters'
require 'model_cache_strategy/adapters_proxy'