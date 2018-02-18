require_relative 'steps'

module Kunkourse
  module BuildPlanner
    class Job
      include Kunkourse::Planner::DSL

      def initialize(job:, repository: Repository::Memory.new)
        @job = job
        @repository = repository
      end

      def plan
        job = @job
        repository = @repository
        serial do
          job.plan.steps.each do |step|
            case step
            when Kunkourse::Task
              task(Steps::CheckResource.new(
                     resource: step.config.image_resource,
                     repository: repository
              ))
              task Steps::Task.new(
                task: step,
                repository: repository
              )
            else
              raise 'Cannot create build plan'
            end
          end
        end
      end
    end
  end
end
