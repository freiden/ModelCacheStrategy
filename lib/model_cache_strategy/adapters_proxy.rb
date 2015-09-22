module ModelCacheStrategy
  class AdaptersProxy
    def self.new(adapters)
      return [] unless adapters.present?
      super
    end

    def initialize(adapters)
      @adapters = Array(adapters)
    end

    def by_type(types)
      types = Array(types)
      chainable_adapters = @adapters.select { |adapter| types.include?(adapter.type) }
      AdaptersProxy.new(chainable_adapters)
    end

    def method_missing(meth, *args, &blk)
      proxying_method(@adapters, meth, *args, &blk)
    end

  private

    def proxying_method(adapters, meth, *args, &blk)
      if adapters.respond_to?(meth)
        adapters.send(meth, *args, &blk)
      else
        adapters.map { |adapter| adapter.send(meth, *args, &blk) }
      end
    end
  end
end