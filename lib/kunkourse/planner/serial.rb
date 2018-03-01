# frozen_string_literal: true

require_relative 'base'
require_relative 'callbacks'

module Kunkourse
  module Planner
    class Serial < Base
      include Callbacks

      def next(states = {})
        return on_failure.next(states) if on_failure?(states)
        return on_success.next(states) if on_success?(states)

        tasks = []
        @tasks.each do |task|
          case task.state(states)
          when :success
            next
          when :failed, :pending
            tasks = []
            break
          when :unstarted
            tasks << task.next(states)
          else
            raise 'Cannot determine serial planner'
          end
        end

        tasks << on_finally.next(states) if on_finally?(states)
        tasks[0, 1].flatten
      end

      private

      def block_state(states = {})
        s = @tasks.map do |task|
          task.state(states)
        end.uniq
        return s.first if s.length == 1
        %i[failed pending unstarted].each do |state|
          return state if s.include?(state)
        end
      end
    end
  end
end
