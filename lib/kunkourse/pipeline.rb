require 'yaml'

module Kunkourse
  Pipeline = Struct.new(:jobs, keyword_init: true) do
    def self.from_file(filename)
      definition = YAML.load_file(filename)
      new(
        jobs: definition.fetch('jobs', []).map do |job|
          Job.from_hash(job)
        end
      )
    end

    Job = Struct.new(:name, :plan, keyword_init: true) do
      def self.from_hash(definition)
        new(
          name: definition.fetch('name'),
          plan: Plan.from_array(definition.fetch('plan', []))
        )
      end

      Plan = Struct.new(:steps, keyword_init: true) do
        def self.from_array(steps)
          new(
            steps: steps.map do |step|
              Task.from_hash(step)
            end
          )
        end

        ImageResource = Struct.new(:type, :source, keyword_init: true) do
          def self.from_hash(definition)
            new(
              type: definition.fetch('type'),
              source: definition.fetch('source', {})
            )
          end
        end

        Task = Struct.new(:name, :config, keyword_init: true) do
          def self.from_hash(definition)
            new(
              name: definition.fetch('task'),
              config: Config.from_hash(definition.fetch('config'))
            )
          end

          Config = Struct.new(:platform, :image_resource, :run, keyword_init: true) do
            def self.from_hash(definition)
              new(
                platform: definition.fetch('platform'),
                image_resource: ImageResource.from_hash(definition.fetch('image_resource')),
                run: Run.from_hash(definition.fetch('run'))
              )
            end

            Run = Struct.new(:path, :args, keyword_init: true) do
              def self.from_hash(definition)
                new(
                  path: definition.fetch('path'),
                  args: definition.fetch('args', [])
                )
              end
            end
          end
        end
      end
    end
  end
end
