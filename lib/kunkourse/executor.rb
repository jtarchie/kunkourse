# frozen_string_literal: true

module Kunkourse
  class Executor < Struct.new(:pipeline, :repository, keyword_init: true)
    class Job < Struct.new(:job, :repository, keyword_init: true)
      def trigger!
        repository.create_build(job: job)
      end
    end

    def run!
      while build = repository.next_build

      end
    end

    def jobs
      @jobs ||= pipeline.jobs.map do |job|
        [job.name, Executor::Job.new(job: job, repository: repository)]
      end.to_h
    end
  end
end
