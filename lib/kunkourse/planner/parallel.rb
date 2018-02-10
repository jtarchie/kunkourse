require_relative 'base'

module Kunkourse
  module Planner
    class Parallel < Base
      def state(states = {})
        s = @tasks.map do |task|
          task.state(states)
        end.uniq
        return s.first if s.length == 1
        %i[unstarted pending failed].each do |state|
          return state if s.include?(state)
        end
      end

      def next(states = {})
        return @failure.first.next(states) if failed?(states) && !@failure.empty?

        tasks = []
        @tasks.each do |task|
          case task.state(states)
          when :success, :failed, :pending
            next
          when :unstarted
            tasks << task.next(states)
          else
            raise 'Cannot determine parallel planner'
          end
        end

        tasks.flatten
      end
    end
  end
end
