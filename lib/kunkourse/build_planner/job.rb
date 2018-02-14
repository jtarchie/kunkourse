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
        job, repository = @job, @repository
        serial do
          job.plan.steps.each do |step|
            case step
            when Kunkourse::Task
              task Steps::CheckResource.new(
                name: "task.#{step.name}.image_resource.check",
                type: step.config.image_resource.type,
                source: step.config.image_resource.source,
                repository: repository
              )
              task Steps::Task.new(
                name: step.name,
                command: [step.config.run.path] + step.config.run.args,
                image_resource_name: "task.#{step.name}.image_resource.check",
                repository: repository
              )
            end
          end
        end
      end
    end
  end
end
