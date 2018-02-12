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
        @success = []
        @finally = []
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

      def success(&block)
        @success << Success.from_block(&block)
      end

      def finally(&block)
        @finally << Finally.from_block(&block)
      end

      def try(&block)
        @tasks << Try.from_block(&block)
      end

      def valid?
        values.length == values.uniq.length &&
          @failure.length <= 1 &&
          @finally.length <= 1 &&
          @success.length <= 1
      end

      def values
        @tasks.flat_map(&:values)
      end

      private

      def on_failure?(states = {})
        !@failure.empty? && block_state(states) == :failed
      end

      def on_failure
        @failure.first
      end

      def on_success?(states = {})
        !@success.empty? && block_state(states) == :success
      end

      def on_success
        @success.first
      end

      def on_finally?(states = {})
        !@finally.empty? &&
          %i[failed success].include?(block_state(states))
      end

      def on_finally
        @finally.first
      end
    end
  end
end
