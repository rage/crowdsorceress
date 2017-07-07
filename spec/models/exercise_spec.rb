# frozen_string_literal: true

require 'rails_helper'
require 'stdout_example'

RSpec.describe Exercise, type: :model do
  describe '.create_file' do
    before :each do
      allow_any_instance_of(Exercise).to receive(:create_model_solution_and_stub)
    end

    subject(:exercise) { FactoryGirl.create(:exercise) }

    it 'creates a submission' do
      exercise.create_submission

      directory = Dir.new('submission_generation/tmp')

      expect(directory.entries).to include("Submission_#{exercise.id}")
      FileUtils.remove_dir("submission_generation/tmp/Submission_#{exercise.id}")
    end

    it 'creates a submission with proper content' do
      pending('Test that submission has right contents')

      src_contents = File.read('submission_generation/Submission/src/Submission.java')
      expect(src_contents).to eq('public class Submission {

  public static void main(String[] args) {

  }

  public static String metodi(String input) {
    asd
  }
}
')

      test_contents = File.read('submission_generation/Submission/test/SubmissionTest.java')
      expect(test_contents).to eq('import fi.helsinki.cs.tmc.edutestutils.Points;
import static org.junit.Assert.assertEquals;
import org.junit.Test;

@Points("01-11")
public class SubmissionTest {

  public SubmissionTest() {

  }

  @Test
  public void test1() {
    toimii("lol", "lolled");
  }


  private void toimii(String input, String output) {
    assertEquals(output, Submission.metodi(input));
  }
}
')

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
        exercise.sandbox_results = { status: '', message: '', passed: true,
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
