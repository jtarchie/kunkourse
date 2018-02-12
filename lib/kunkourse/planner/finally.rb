module Kunkourse
  module Planner
    class Finally < Base
      def next(states = {})
        @tasks.first.next(states)
      end

      def state(states = {})
        @tasks.first.state(states)
      end
    end
  end
end
