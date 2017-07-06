# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExerciseVerifierJob, type: :job do
  describe '#perform_later' do
    let(:exercise) { FactoryGirl.create(:exercise) }
    before :each do
      allow_any_instance_of(ExerciseVerifierJob).to receive(:sandbox_post)
      # allow_any_instance_of(ExerciseVerifierJob).to receive(:create_tar_files)
      # allow_any_instance_of(Exercise).to receive(:create_model_solution_and_stub)
    end

    it 'enqueues a job' do
      ActiveJob::Base.queue_adapter = :test
      expect do
        ExerciseVerifierJob.perform_later(exercise)
      end.to have_enqueued_job
    end

    it 'sends exercise to backend' do
      exercise.sandbox_results = { status: '', message: '', passed: true,
                                   model_results_received: false, stub_results_received: false }

      ExerciseVerifierJob.perform_now(exercise)
      expect(exercise.status).to eq('testing_model_solution')

      FileUtils.remove_dir("submission_generation/tmp/Submission_#{exercise.id}")
      FileUtils.remove_entry("submission_generation/packages/ModelSolutionPackage_#{exercise.id}.tar")
      FileUtils.remove_entry("submission_generation/packages/StubPackage_#{exercise.id}.tar")
    end
  end
end
