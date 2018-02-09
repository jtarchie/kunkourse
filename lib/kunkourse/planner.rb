module Kunkourse
  module Planner
    class Task
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def state(states = {})
        states[@value]
      end

      def next(*)
        [@value]
      end
    end

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
    end

    class Parallel < Base
      def state(states = {})
        s = @tasks.map do |task|
          task.state(states)
        end.uniq
        return s.first if s.length == 1
        return :failed if s.include?(:failed)
        return :pending if s.include?(:pending)
      end

      def next(states = {})
        tasks = []
        @tasks.each do |task|
          case task.state(states)
          when :success, :failed, :pending
            next
          else
            tasks << task.next(states)
          end
        end

        tasks.flatten
      end
    end

    class Serial < Base
      def state(states = {})
        s = @tasks.map do |task|
          task.state(states)
        end.uniq
        return :success if s == [:success]
        return :failed if s.include?(:failed)
        return :pending if s.include?(:pending)
      end

      def next(states = {})
        tasks = []
        @tasks.each do |task|
          case task.state(states)
          when :success
            next
          when :failed, :pending
            return []
          else
            tasks << task.next(states)
          end
        end

        tasks[0, 1].flatten
      end
    end

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
