require 'spec_helper'

RSpec.describe 'Build Planner' do
  context 'given the hello world pipeline' do
    include Kunkourse::Planner::DSL

    let(:pipeline) { Kunkourse::Pipeline.from_file(File.join(__dir__, 'fixtures', 'hello.yml')) }
    let(:job) { pipeline.jobs.first }

    it 'generates a serial plan for the job' do
      expected_plan = serial do
        task 'task.say-hello.resource.check'
        task 'task.say-hello.execute'
      end
      actual_plan = Kunkourse::BuildPlanner.new(job).plan
      expect(expected_plan).to eq actual_plan
    end
  end
end
