require_relative 'base'

module Kunkourse
  module Planner
    class Serial < Base
      def state(states = {})
        s = @tasks.map do |task|
          task.state(states)
        end.uniq
        return s.first if s.length == 1
        %i[failed pending unstarted].each do |state|
          return state if s.include?(state)
        end
      end

      def next(states = {})
        return @failure.first.next(states) if failed?(states) && !@failure.empty?
        return @success.first.next(states) if success?(states) && !@success.empty?

        tasks = []
        @tasks.each do |task|
          case task.state(states)
          when :success
            next
          when :failed, :pending
            return []
          when :unstarted
            tasks << task.next(states)
          else
            raise 'Cannot determine serial planner'
          end
        end

        tasks[0, 1].flatten
      end
    end
  end
end
