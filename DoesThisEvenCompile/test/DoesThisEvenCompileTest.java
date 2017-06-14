import fi.helsinki.cs.tmc.edutestutils.Points;
import static org.junit.Assert.assertEquals;
import org.junit.Test;

@Points("01-11")
public class DoesThisEvenCompileTest {

  public DoesThisEvenCompileTest() {

  }

  @Test
  public void test1() {
    toimii("asd", "asdasdasd");
  }


  private void toimii(String input, String output) {
    assertEquals(output, DoesThisEvenCompile.metodi(input));
  }
}
