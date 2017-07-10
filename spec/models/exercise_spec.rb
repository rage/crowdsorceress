# frozen_string_literal: true

require 'rails_helper'
require 'stdout_example'

RSpec.describe Exercise, type: :model do
  describe '.create_submission' do
    subject(:exercise) { FactoryGirl.create(:exercise) }

    it 'creates a submission' do
      exercise.create_submission

      directory = Dir.new('submission_generation/tmp')

      expect(directory.entries).to include("Submission_#{exercise.id}")
      FileUtils.remove_dir("submission_generation/tmp/Submission_#{exercise.id}")
    end

    it 'creates a submission with proper contents' do
      exercise.create_submission

      directory = Dir.new("submission_generation/tmp/Submission_#{exercise.id}")
      expect(directory.entries).to include('model', 'stub')

      FileUtils.remove_dir("submission_generation/tmp/Submission_#{exercise.id}")
    end
  end

  describe '.handle_results' do
    subject(:exercise) { FactoryGirl.create(:exercise) }

    context 'stub does not compile and tests fail' do
      it 'handles sandbox results properly' do
        exercise.code =
          'System.out.println("moi");
           // BEGIN SOLUTION
           return "Hello " + input;
           // END SOLUTION'
        exercise.sandbox_results = { status: '', message: '', passed: false,
                                     model_results_received: false, stub_results_received: false }

        # Handle model solutions results
        exercise.handle_results('finished', { 'status' => 'TESTS_FAILED',
                                              'testResults' => [{ 'name' => 'ModelSolutionTest test1', 'successful' => false,
                                                                  'message' => 'ComparisonFailure: expected:<Hello[lolled]> but was: <Hello [lol]>',
                                                                  'valgrindFailed' => false, 'points' => ['01-11'],
                                                                  'exception' => ['expected:<Hello[lolled]> but was: <Hello [lol]>'] }],
                                              'logs' => { 'stdout' => [109, 111, 105, 10], 'stderr' => [] } }, 'MODEL_KISSA')
        # Handle stubs results
        exercise.handle_results('finished', { 'status' => 'COMPILE_FAILED', 'testResults' => [],
                                              'logs' => { 'stdout' => StdoutExample.new.example, 'stderr' => [] } }, 'KISSA_STUB')

        expect(exercise.sandbox_results[:passed]).to be(false)
        expect(exercise.sandbox_results[:status]).not_to be('finished')
        expect(exercise.sandbox_results[:message]).to include('Malliratkaisun tulokset: Testit eivät menneet läpi.',
                                                              'Tehtäväpohjan tulokset: Koodi ei kääntynyt.')
        expect(exercise.error_messages).to include('ComparisonFailure: expected:<Hello[lolled]> but was: <Hello [lol]>', 'Tehtäväpohja ei kääntynyt: ')
      end
    end
  end
end
