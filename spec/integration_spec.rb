# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Integration Suite' do
  xit 'handles a simple pipeline' do
    repository = Kunkourse::Repository::Memory.new
    pipeline = Kunkourse::Pipeline.from_file(File.join(__dir__, 'fixtures', 'hello.yml'))
    executor = Kunkourse::Executor.new(
      pipeline: pipeline,
      repository: repository
    )
    Thread.new { executor.run! }

    job = executor.jobs.fetch('hello-world')
    job.trigger!

    wait_for do
      repository.get_output(name: 'task.say-hello')
    end.to eq "Hello, world!\n"
  end
end
