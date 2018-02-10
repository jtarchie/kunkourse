module Kunkourse
  module Planner
    class Task
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def state(states = {})
        states[@value]
      end

      def next(*)
        [@value]
      end
    end
  end
end
