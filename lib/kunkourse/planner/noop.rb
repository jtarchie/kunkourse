
module Kunkourse
  module Planner
    class Noop
      def state(states = {})
        :success
      end

      def next(states = {})
        []
      end

      def values
        []
      end
    end
  end
end
