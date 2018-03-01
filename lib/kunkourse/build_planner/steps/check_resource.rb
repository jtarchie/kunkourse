# frozen_string_literal: true

require 'json'

module Kunkourse
  module BuildPlanner
    module Steps
      CheckResource = Struct.new(:resource, :repository, keyword_init: true) do
        def execute!
          repository.create_container(
            name: name,
            image: "concourse/#{resource.type}-resource",
            command: ['sh', '-c', "echo '#{json_payload}' | /opt/resource/check"]
          )
        end

        def state
          repository.container_status(
            name: name
          )
        end

        def tick!
          if state == :success
            output = repository.container_output(name: name)
            versions = JSON.parse(output.split("\n").last)
            versions.each do |version|
              repository.create_version(name: name, version: version)
            end
          end
        end

        private

        def json_payload
          { source: resource.source }.to_json
        end

        def name
          "image_resource.check.#{resource.hash}"
        end
      end
    end
  end
end
