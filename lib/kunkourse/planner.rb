module Kunkourse
  module Planner
    class Task
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def state(states={})
        states[@value]
      end

      def next(*)
        [@value]
      end
    end

    class Parallel
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
        @tasks << self.class.from_block(&block)
      end

      def next(states = {})
        if states.empty?
          @tasks.flat_map(&:next)
        else
          []
        end
      end
    end

    class Serial
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
        @tasks << self.class.from_block(&block)
      end

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
            tasks += task.next(states)
          end
        end

        tasks[0,1]
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
