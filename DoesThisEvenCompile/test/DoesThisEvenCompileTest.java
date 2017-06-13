import static org.junit.Assert.assertEquals;
import org.junit.Test;

public class DoesThisEvenCompileTest {

  public DoesThisEvenCompileTest() {

  }

  @Test
  public void test1() {
    toimii(asd, asdasdasd);
  }


  private void toimii(String input, String output) {
    assertEquals(output, DoesThisEvenCompile.method(input));
  }
}
