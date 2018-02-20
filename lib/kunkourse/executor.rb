module Kunkourse
  Executor = Struct.new(:pipeline, :repository, keyword_init: true) do
    def run!; end
  end
end
