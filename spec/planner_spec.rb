require 'spec_helper'

RSpec.describe 'Planner' do
  include Kunkourse::Planner::DSL

  context 'with a single step' do
    shared_examples 'single step plan' do
      it 'returns the step when it has not executed' do
        steps = plan.next
        expect(steps).to eq [:A]
      end

      it 'returns nothing once it pending' do
        steps = plan.next(A: :pending)
        expect(steps).to be_empty
      end

      it 'returns nothing once it success' do
        steps = plan.next(A: :success)
        expect(steps).to be_empty
      end

      it 'returns nothing once it failed' do
        steps = plan.next(A: :failed)
        expect(steps).to be_empty
      end
    end

    context 'in serial' do
      let(:plan) do
        serial do
          task :A
        end
      end
      it_behaves_like 'single step plan'
    end

    context 'in parallel' do
      let(:plan) do
        parallel do
          task :A
        end
      end
      it_behaves_like 'single step plan'
    end
  end

  context 'with two serial steps' do
    shared_examples 'multiple serial steps plan' do
      it 'returns the first step when it has not executed' do
        steps = plan.next
        expect(steps).to eq [:A]
      end

      it 'returns nothing when the first step is pending' do
        expect(plan.next(A: :pending)).to be_empty
      end

      it 'returns the next step on first success' do
        expect(plan.next(A: :success)).to eq [:B]
      end

      it 'returns nothing when the first step has failed' do
        expect(plan.next(A: :failed)).to be_empty
      end

      context 'when the final step has finished' do
        it 'returns no steps' do
          expect(plan.next(A: :success, B: :success)).to eq []
        end
      end
    end

    context 'with two tasks' do
      let(:plan) do
        serial do
          task :A
          task :B
        end
      end
      it_behaves_like 'multiple serial steps plan'
    end

    context 'with a nested serial step' do
      context 'first is serial' do
        let(:plan) { serial { serial { task :A }; task :B } }
        it_behaves_like 'multiple serial steps plan'
      end

      context 'second is serial' do
        let(:plan) { serial { task :A; serial { task :B } } }
        it_behaves_like 'multiple serial steps plan'
      end

      context 'both are serial' do
        let(:plan) { serial { serial { task :A }; serial { task :B } } }
        it_behaves_like 'multiple serial steps plan'
      end

      context 'with a nested serials' do
        let(:plan) { serial { serial { serial { task :A; task :B } } } } 
        it_behaves_like 'multiple serial steps plan'
      end
    end
  end
end
