module Kunkourse
  module Planner
    class Try < Base
      def state(states = {})
        s = @tasks.first.state(states)
        return :success if s == :failed
        s
      end

      def next(states = {})
        @tasks.first.next(states)
      end
    end
  end
end
