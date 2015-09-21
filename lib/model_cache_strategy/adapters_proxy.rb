module ModelCacheStrategy
  class AdaptersProxy
    def self.new(adapters)
      return [] unless adapters.present?
      super
    end

    def initialize(adapters)
      @adapters = Array(adapters)
    end

    def by_type(type)
      chainable_adapters = @adapters.select { |adapter| type == adapter.type }
      AdaptersProxy.new(chainable_adapters)
    end

    def method_missing(meth, *args)
      proxying_method(@adapters, meth, *args)
    end


  private

    def proxying_method(adapters, meth, *args)
      if adapters.respond_to?(meth)
        adapters.send(meth, *args)
      else
        adapters.map { |adapter| adapter.send(meth, *args) }
      end
    end
  end
end