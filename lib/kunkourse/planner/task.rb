# frozen_string_literal: true

module Kunkourse
  module Planner
    class Task
      def initialize(value)
        @value = value
      end

      def state(states = {})
        states[@value] || :unstarted
      end

      def next(states = {})
        return [@value] if state(states) == :unstarted
        []
      end

      def values
        [@value]
      end
    end
  end
end
