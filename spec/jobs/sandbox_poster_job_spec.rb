# frozen_string_literal: true

require 'rails_helper'
require 'tarballer'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe SandboxPosterJob, type: :job do
  let(:exercise) { FactoryGirl.create(:exercise) }

  describe 'SandboxPosterJob' do
    context 'when performing a job' do
      it 'pushes the job into the queue' do
        assert_equal 0, SandboxPosterJob.jobs.size
        expect do
          SandboxPosterJob.perform_async(exercise.id)
        end.to change(SandboxPosterJob.jobs, :size).by(1)
        assert_equal 1, SandboxPosterJob.jobs.size
      end
    end
  end
end
