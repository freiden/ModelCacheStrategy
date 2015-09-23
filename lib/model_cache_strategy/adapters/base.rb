module ModelCacheStrategy
  module Adapters
    class Base

      def expire!
        raise 'TBD in each adapter'
      end

      def cache_control(_)
        []
      end

      def set_expiration(name, ids = [])
        raise 'TBD in each adapter'
      end

      def type
        raise 'TBD in each adapter'
      end

      def enabled?
        true
      end
    end
  end
end