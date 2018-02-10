module Kunkourse
  module Planner
    class Success < Base
      def next(states = {})
        @tasks.first.next(states)
      end
    end
  end
end
