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
        @failure = []
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

      def failure(&block)
        @failure << Failure.from_block(&block)
      end

      def valid?
        values.length == values.uniq.length &&
          @failure.length <= 1
      end

      def failed?(states = {})
        state(states) == :failed
      end

      def values
        @tasks.flat_map do |task|
          case task
          when Task
            task.value
          else
            task.values
          end
        end
      end
    end
  end
end
