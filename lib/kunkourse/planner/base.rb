require_relative 'task'
require_relative 'noop'

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
        @failure = Noop.new
        @success = Noop.new
        @finally = Noop.new
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
        @failure = Failure.from_block(&block)
      end

      def success(&block)
        @success = Success.from_block(&block)
      end

      def finally(&block)
        @finally = Finally.from_block(&block)
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

      def state(states = {})
        s = [
          block_state(states),
          on_success.state(states),
          on_finally.state(states)
        ].uniq!
        return s.first if s.length == 1
        %i[failed pending unstarted].each do |state|
          return state if s.include?(state)
        end
      end


      private

      def on_failure?(states = {})
        !on_failure.next(states).empty? &&
          block_state(states) == :failed
      end

      def on_failure
        @failure
      end

      def on_success?(states = {})
        !on_success.next(states).empty? &&
          block_state(states) == :success
      end

      def on_success
        @success
      end

      def on_finally?(states = {})
        !on_finally.next(states).empty? &&
          %i[failed success].include?(block_state(states))
      end

      def on_finally
        @finally
      end
    end
  end
end
