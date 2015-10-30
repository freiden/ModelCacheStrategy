module ModelCacheStrategy
  module Adapters
    class Base
      # Method allowing to retrieve current class descendants:
      def self.descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def self.type
        raise 'TBD in each adapter'
      end

      def expire!
        raise 'TBD in each adapter'
      end

      def cache_control(_)
        []
      end

      def set_expiration(name, ids = [])
        raise 'TBD in each adapter'
      end

      def set_global_expiration(resources_to_expire, ids)
        raise 'TBD in each adapter'
      end

      def type
        raise 'TBD in each adapter'
      end

      def reset!
        raise 'TBD in each adapter'
      end
    end
  end
end