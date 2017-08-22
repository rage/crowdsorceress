# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeoutCheckerJob, type: :job do
  describe 'TimeoutChecker' do
    let(:exercise) { FactoryGirl.create(:exercise) }

    context 'when exercise status is finished or error' do
      it 'does nothing' do
        exercise.finished!
        TimeoutCheckerJob.perform_now(exercise)
        expect(exercise.status).to eq('finished')

        exercise.error!
        TimeoutCheckerJob.perform_now(exercise)
        expect(exercise.status).to eq('error')
      end
    end

    context 'when exercise status is anything but finished or error' do
      it 'changes exercise status to timeout' do
        exercise.half_done!
        TimeoutCheckerJob.perform_now(exercise)
        expect(exercise.status).to eq('sandbox_timeout')
      end
    end
  end
end
