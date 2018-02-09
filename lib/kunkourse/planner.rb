module Kunkourse
  module Planner
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
        @tasks << value
      end

      def next(states = {})
        return @tasks if states.empty?
        []
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
        @tasks << value
      end

      def serial(&block)
        @tasks << self.class.from_block(&block)
      end

      def next(states = {})
        puts "tasks: #{@tasks}"
        @tasks.each do |task|
          puts "\ttask: #{task}"
          case states[task]
          when :success
            next
          when :failed, :pending
            return []
          else
            case task
            when Serial
              return task.next(states)
            else
              return [task]
            end
          end
        end

        []
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
