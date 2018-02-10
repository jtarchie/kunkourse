require_relative 'base'

module Kunkourse
  module Planner
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
  end
end
