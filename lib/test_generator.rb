class TestGenerator

  # def initialize(exercise_type)
  #   @exercise_type = exercise_type
  # end

  def generate(exercise_type)
    # raise 'Unsupported exercise type.' unless @exercise_type == :string_string
    if exercise_type == :string_string
      return string_to_string
    end
  end

  def string_to_string
    <<-eos
public class StringToStringTest {

  @Test
  public void toimii(input, output) {
    ReflectionUtils.newInstanceOfClass(TulostusKolmesti.class); // Exercise.code
    io.setSysIn(input + "\n");
    try {
        TulostusKolmesti.main(new String[0]);
    } catch (NumberFormatException e) {
        fail("Kun luet käyttäjältä merkkijonoa, älä yritä muuttaa sitä numeroksi. Virhe: " + e.getMessage());
    }

    String out = io.getSysOut();

    assertTrue("Kun syöte on \"" + input + "\" pitäisi tulostuksessa olla teksti \"" + output + "\", nyt ei ollut. Tulosteesi oli: "+out,
                out.contains(output));
  }
}
eos
  end
  
end
