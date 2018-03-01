# frozen_string_literal: true

require_relative 'serial'
require_relative 'parallel'

module Kunkourse
  module Planner
    module DSL
      def serial(&block)
        Serial.from_block(&block)
      end

      def parallel(&block)
        Parallel.from_block(&block)
      end
    end
  end
end
