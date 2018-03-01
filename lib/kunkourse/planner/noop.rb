
# frozen_string_literal: true

module Kunkourse
  module Planner
    class Noop
      def state(_states = {})
        :success
      end

      def next(_states = {})
        []
      end

      def values
        []
      end
    end
  end
end
