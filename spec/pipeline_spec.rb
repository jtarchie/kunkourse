require 'spec_helper'

RSpec.describe Kunkourse::Pipeline do
  context '.from_file' do
    it 'fails on missing file' do
      expect do
        described_class.from_file('none')
      end.to raise_error(Errno::ENOENT)
    end

    it 'has defaults' do
      pipeline = described_class.from_file(File.join(__dir__, 'fixtures', 'empty.yml'))
      expect(pipeline.jobs).to be_empty
    end

    context 'with a valid pipeline' do
      it 'loads jobs' do
        pipeline = described_class.from_file(File.join(__dir__, 'fixtures', 'hello.yml'))
        expect(pipeline.jobs).to_not be_empty

        job = pipeline.jobs.first
        expect(job.name).to eq 'hello-world'
        expect(job.plan.steps).to_not be_empty

        task = job.plan.steps.first
        expect(task.name).to eq 'say-hello'
      end
    end
  end
end
