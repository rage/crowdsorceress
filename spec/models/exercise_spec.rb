# frozen_string_literal: true

require 'rails_helper'
require 'stdout_example'
require 'zip'
require 'zip_handler'

RSpec.describe Exercise, type: :model do
  subject(:exercise) { FactoryGirl.create(:exercise) }

  describe 'when receiving a new submission' do
    it 'creates a submission' do
      exercise.create_submission

      directory = Dir.new('submission_generation/tmp')

      expect(directory.entries).to include("Submission_#{exercise.id}")
      FileUtils.remove_dir("submission_generation/tmp/Submission_#{exercise.id}")
    end

    it 'creates a submission with proper contents' do
      exercise.create_submission

      directory = Dir.new("submission_generation/tmp/Submission_#{exercise.id}")
      expect(directory.entries).to include('model', 'template')

      FileUtils.remove_dir("submission_generation/tmp/Submission_#{exercise.id}")
    end
  end

  describe 'when receiving results from sandbox' do
    context 'when template does not compile and tests fail' do
      it 'handles sandbox results properly' do
        exercise.code =
          'System.out.println("moi");
           // BEGIN SOLUTION
           return "Hello " + input;
           // END SOLUTION'
        exercise.sandbox_results = { status: '', message: '', passed: false,
                                     model_results_received: false, template_results_received: false }

        # Handle model solutions results
        exercise.handle_results({ 'status' => 'TESTS_FAILED', 'testResults' =>
          [{ 'name' => 'ModelSolutionTest test1', 'successful' => false, 'message' => 'ComparisonFailure: expected:<Hello[lolled]> but was: <Hello [lol]>',
             'valgrindFailed' => false, 'points' => ['01-11'], 'exception' => ['expected:<Hello[lolled]> but was: <Hello [lol]>'] }],
                                  'logs' => { 'stdout' => [109, 111, 105, 10], 'stderr' => [] } }, 'MODEL')
        # Handle template's results
        exercise.handle_results({ 'status' => 'COMPILE_FAILED', 'testResults' => [], 'logs' =>
          { 'stdout' => StdoutExample.new.example, 'stderr' => [] } }, 'TEMPLATE')

        expect(exercise.sandbox_results[:passed]).to be(false)
        expect(exercise.sandbox_results[:status]).not_to be('finished')
        expect(exercise.sandbox_results[:message]).to include('Results for the model solution: Tests did not pass.',
                                                              'Results for the template: Code did not compile.')
        expect(exercise.error_messages.first['messages']).to include('ComparisonFailure: expected:<Hello[lolled]> but was: <Hello [lol]>')
      end
    end
  end

  describe 'when all exercise\'s tests have passed on sandbox' do
    it 'creates a zip' do
      exercise.create_submission
      ZipHandler.new(exercise).clean_up

      expect(File).to exist(exercise_target_path.join("ModelSolution_#{exercise.id}.#{exercise.versions.last.id}.zip"))
      expect(File).to exist(exercise_target_path.join("Template_#{exercise.id}.#{exercise.versions.last.id}.zip"))

      FileUtils.remove_dir("submission_generation/packages/assignment_#{exercise.assignment.id}/")
    end

    it 'creates a zip with proper contents' do
      exercise.create_submission
      ZipHandler.new(exercise).clean_up

      Zip::File.open(exercise_target_path.join("ModelSolution_#{exercise.id}.#{exercise.versions.last.id}.zip")) do |zip_file|
        zip_file.each do |file|
          file_path = File.join(exercise_target_path, file.name)
          FileUtils.mkdir_p(File.dirname(file_path))
          zip_file.extract(file, file_path) unless File.exist?(file_path)
        end
      end

      expect(File).to exist(exercise_target_path.join('src', 'Submission.java'))
      expect(File).to exist(exercise_target_path.join('lib', 'testrunner', 'tmc-junit-runner.jar'))

      FileUtils.remove_dir("submission_generation/packages/assignment_#{exercise.assignment.id}/")
    end
  end

  private

  def exercise_target_path
    Rails.root.join('submission_generation', 'packages', "assignment_#{exercise.assignment.id}", "exercise_#{exercise.id}")
  end
end
