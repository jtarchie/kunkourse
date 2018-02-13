require_relative 'task'

module Kunkourse
  module Planner
    class Base
      def self.from_block(&block)
        s = new
        s.instance_eval(&block)
        s
      end

      def initialize
        @tasks = []
      end

      def task(value)
        @tasks << Task.new(value)
      end

      def serial(&block)
        @tasks << Serial.from_block(&block)
      end

      def parallel(&block)
        @tasks << Parallel.from_block(&block)
      end

      def try(&block)
        @tasks << Try.from_block(&block)
      end

      def valid?
        values.length == values.uniq.length
      end

      def values
        @tasks.flat_map(&:values)
      end
    end
  end
end
