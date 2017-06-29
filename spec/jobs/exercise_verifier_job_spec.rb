# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExerciseVerifierJob, type: :job do
  describe '#perform_later' do
    let(:exercise) { FactoryGirl.create(:exercise) }
    before :each do
      allow_any_instance_of(ExerciseVerifierJob).to receive(:sandbox_post)
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
    end
  end
end
