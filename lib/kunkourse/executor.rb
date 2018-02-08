module Kunkourse
  Executor = Struct.new(:pipeline, keyword_init: true) do
    attr_reader :jobs

    def run!
      @jobs = pipeline.jobs.map do |job|
        Executor::Job.new(job)
      end
    end
  end
end
