# frozen_string_literal: true

module Kunkourse
  module BuildPlanner
    module Steps
      Task = Struct.new(:task, :repository, keyword_init: true) do
        def execute!
          latest_version = repository.latest_version(name: image_resource_name)
          digest = latest_version.fetch('digest')

          repository.create_container(
            name: name,
            image: "#{task.config.image_resource.source.fetch('repository')}@#{digest}",
            command: [task.config.run.path] + task.config.run.args
          )
        end

        def state
          repository.container_status(
            name: name
          )
        end

        def tick!
          output = repository.container_output(name: name)
          repository.set_output(
            name: name,
            output: output
          )
        end

        private

        def name
          "task.#{task.name}"
        end

        def image_resource_name
          "image_resource.check.#{task.config.image_resource.hash}"
        end
      end
    end
  end
end
