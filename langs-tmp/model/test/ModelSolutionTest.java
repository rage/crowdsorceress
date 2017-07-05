import fi.helsinki.cs.tmc.edutestutils.Points;
import static org.junit.Assert.assertEquals;
import org.junit.Test;

@Points("01-11")
public class ModelSolutionTest {

  public ModelSolutionTest() {

  }

  @Test
  public void test1() {
    toimii("testi", "Hello asdf");
  }


  private void toimii(String input, String output) {
    assertEquals(output, ModelSolution.metodi(input));
  }
}


