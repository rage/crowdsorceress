# frozen_string_literal: true

require 'rails_helper'
require 'tar_baller'

RSpec.describe TimeoutCheckerJob, type: :job do
  describe 'TimeoutChecker' do
    let(:exercise) { FactoryGirl.create(:exercise) }
    before :each do
      allow_any_instance_of(ExerciseVerifierJob).to receive(:sandbox_post)
    end

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
      it 'calls ExerciseVerifierJob' do
        exercise.half_done!
        TarBaller.new.create_tar_files(exercise)

        expect do
          TimeoutCheckerJob.perform_now(exercise)
        end.to change { exercise.times_sent_to_sandbox }.by(1)

        FileUtils.remove_dir("submission_generation/tmp/Submission_#{exercise.id}")
        FileUtils.remove_entry("submission_generation/packages/ModelSolutionPackage_#{exercise.id}.tar")
        FileUtils.remove_entry("submission_generation/packages/TemplatePackage_#{exercise.id}.tar")
      end
    end
  end
end
