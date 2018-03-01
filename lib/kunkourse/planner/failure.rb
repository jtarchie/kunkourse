# frozen_string_literal: true

module Kunkourse
  module Planner
    class Failure < Base
      def next(states = {})
        @tasks.first.next(states)
      end
    end
  end
end
