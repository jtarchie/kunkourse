module Kunkourse
  module BuildPlanner
    module Steps
      CheckResource = Struct.new(:name, :type, :source, :repository, keyword_init: true) do
        def execute!

        end

        def pending?

        end

        def failed?

        end

        def success?

        end
      end
      Task = Struct.new(:name, :command, :image_resource_name, :repository, keyword_init: true) do
        def execute!

        end

        def pending?

        end

        def failed?

        end

        def success?

        end
      end
    end
  end
end
