require_relative 'base'

module Kunkourse
  module Planner
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
  end
end
