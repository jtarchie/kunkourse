require 'spec_helper'

RSpec.describe 'Integration Suite' do
  xit 'handles a simple pipeline' do
    pipeline = Kunkourse::Pipeline.from_file(File.join(__dir__, 'fixtures', 'hello.yml'))
    executor = Kunkourse::Executor.new(
      pipeline: pipeline,
      repository: Repository::Memory.new
    )

    job = executor.jobs.fetch('hello-world')
    job.trigger!

    task = job.plan.last
    expect(task.output).to eq "Hello, world!\n"
  end
end
