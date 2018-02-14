require 'spec_helper'

RSpec.describe 'Build Planner' do
  context 'given the hello world pipeline' do
    include Kunkourse::Planner::DSL

    let(:pipeline) { Kunkourse::Pipeline.from_file(File.join(__dir__, 'fixtures', 'hello.yml')) }
    let(:job) { pipeline.jobs.first }

    it 'generates a serial plan for the job' do
      repository = Kunkourse::Repository::Memory.new
      expected_plan = serial do
        task Kunkourse::BuildPlanner::Steps::CheckResource.new(
          name: 'task.say-hello.image_resource.check',
          repository: repository,
          source: {'repository' => 'busybox'},
          type: 'docker-image',
        )
        task Kunkourse::BuildPlanner::Steps::Task.new(
          command: ['echo', 'Hello, world!'],
          image_resource_name: 'task.say-hello.image_resource.check',
          name: 'say-hello',
          repository: repository,
        )
      end
      actual_plan = Kunkourse::BuildPlanner::Job.new(
        job: job,
        repository: repository
      ).plan
      expect(expected_plan).to eq actual_plan
    end
  end
end
