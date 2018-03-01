# frozen_string_literal: true

module Kunkourse
  module Planner
    class Success < Base
      def next(states = {})
        @tasks.first.next(states)
      end

      def state(states = {})
        @tasks.first.state(states)
      end
    end
  end
end
