# frozen_string_literal: true

require 'rails_helper'
require 'stdout_example'

RSpec.describe Exercise, type: :model do
  describe '.create_file' do
    subject(:exercise) { FactoryGirl.create(:exercise) }

    it 'creates a stub file' do
      exercise.create_file('stubfile')
      contents = File.read('Stub/src/Stub.java')
      expect(contents).to eq('public class Stub {

  public static void main(String[] args) {

  }

  public static String metodi(String input) {
    asd
  }
}
')
    end

    it 'creates a model solution file' do
      exercise.create_file('model_solution_file')
      contents = File.read('ModelSolution/src/ModelSolution.java')
      expect(contents).to eq('public class ModelSolution {

  public static void main(String[] args) {

  }

  public static String metodi(String input) {
    asd
  }
}
')
    end

    it 'creates a test file' do
      exercise.create_file('testfile')
      contents = File.read('ModelSolution/test/ModelSolutionTest.java')
      expect(contents).to eq('import fi.helsinki.cs.tmc.edutestutils.Points;
import static org.junit.Assert.assertEquals;
import org.junit.Test;

@Points("01-11")
public class ModelSolutionTest {

  public ModelSolutionTest() {

  }

  @Test
  public void test1() {
    toimii("lol", "lolled");
  }


  private void toimii(String input, String output) {
    assertEquals(output, ModelSolution.metodi(input));
  }
}
')
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
