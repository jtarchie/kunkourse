require_relative 'planner'

module Kunkourse
  class BuildPlanner
    include Kunkourse::Planner::DSL

    def initialize(job)
      @job = job
    end

    def plan
      job = @job
      serial do
        job.plan.steps.each do |step|
          case step
          when Kunkourse::Task
            task "task.#{step.name}.resource.check"
            task "task.#{step.name}.execute"
          end
        end
      end
    end
  end
end
