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

      it 'should be a valid plan' do
        expect(plan).to be_valid
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

      it 'should be a valid plan' do
        expect(plan).to be_valid
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

  context 'with two steps in parallel' do
    shared_examples 'multiple steps in parallel' do
      it 'returns all steps with no state' do
        steps = plan.next
        expect(steps).to eq %i[A B]
      end

      it 'returns the other step when one is pending' do
        expect(plan.next(A: :pending)).to eq [:B]
        expect(plan.next(B: :pending)).to eq [:A]
      end

      it 'returns no steps when on is success' do
        expect(plan.next(A: :success)).to eq [:B]
        expect(plan.next(B: :success)).to eq [:A]
      end

      it 'returns no steps when on is success' do
        expect(plan.next(A: :failed)).to eq [:B]
        expect(plan.next(B: :failed)).to eq [:A]
      end

      it 'should be a valid plan' do
        expect(plan).to be_valid
      end
    end

    context 'with two tasks' do
      let(:plan) { parallel { task :A; task :B } }
      it_behaves_like 'multiple steps in parallel'
    end

    context 'with one task and one serial' do
      let(:plan) { parallel { task :A; serial { task :B } } }
      it_behaves_like 'multiple steps in parallel'
    end
  end

  context 'with composed serial and parallel' do
    let(:plan) do
      serial do
        parallel do
          task :A
          task :B
          serial do
            task :C
            task :D
          end
          parallel do
            task :E
            serial do
              task :F1
              task :F2
            end
          end
        end
        task :G
      end
    end

    it 'should be a valid plan' do
      expect(plan).to be_valid
    end

    it 'has an initial state' do
      steps = plan.next
      expect(steps).to eq %i[A B C E F1]
    end

    it 'recommends based on a success state is successful' do
      expect(plan.next(A: :success)).to eq %i[B C E F1]
      expect(plan.next(
               A: :success,
               B: :success,
               C: :success,
               E: :success
      )).to eq %i[D F1]
    end

    it 'recommends steps if something fails' do
      expect(plan.next(A: :failed)).to eq %i[B C E F1]
      expect(plan.next(
               A: :success,
               B: :success,
               C: :success,
               E: :failed
      )).to eq %i[D F1]
    end

    it 'recommends steps if something is pending' do
      expect(plan.next(A: :pending)).to eq %i[B C E F1]
      expect(plan.next(
               A: :success,
               B: :success,
               C: :success,
               E: :pending
      )).to eq %i[D F1]
    end

    it 'recommends the last serial step if everything is successful' do
      expect(plan.next(
               A: :success,
               B: :success,
               C: :success,
               D: :success,
               E: :success,
               F1: :success,
               F2: :success
      )).to eq [:G]
    end
  end

  context 'with failure action' do
    context 'for a serial plan' do
      let(:plan) do
        serial do
          task :A
          task :B
          failure do
            task :C
          end
        end
      end

      it 'does not run the failure on success' do
        expect(plan.next(A: :success, B: :success)).to be_empty
      end

      it 'does run failure on a failing task' do
        expect(plan.next(A: :failed)).to eq [:C]
        expect(plan.next(A: :success, B: :failed)).to eq [:C]
      end

      it 'has a failure state for the plan' do
        expect(plan.state(A: :failed)).to eq :failed
        expect(plan.state(A: :success, B: :failed)).to eq :failed
      end
    end

    context 'for a parallel plan' do
      let(:plan) do
        parallel do
          task :A
          task :B
          failure do
            task :C
          end
        end
      end

      it 'does not run the failure on success' do
        expect(plan.next(A: :success, B: :success)).to be_empty
      end

      it 'does run failure on a failing task' do
        expect(plan.next(A: :failed)).to eq [:B]
        expect(plan.next(A: :success, B: :failed)).to eq [:C]
        expect(plan.next(A: :failed, B: :success)).to eq [:C]
      end

      it 'has a failure state for the plan' do
        expect(plan.state(A: :failed)).to eq :unstarted
        expect(plan.state(A: :success, B: :failed)).to eq :failed
      end
    end
  end

  context 'with success action' do
  end

  context 'with a try action' do
  end

  context 'with ensure action' do
  end

  context '#valid?' do
    it 'only allows the same task to be declared once' do
      expect(serial { task :A; task :A }).to_not be_valid
      expect(parallel { task :A; task :A }).to_not be_valid
      expect(parallel { serial { task :A }; serial { task :A } }).to_not be_valid
    end

    it 'only allows one failure to be defined' do
      expect(serial { failure { task :A }; failure { task :B } }).to_not be_valid
    end
  end
end
