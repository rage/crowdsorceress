require 'rails_helper'
require 'test_generator'

RSpec.describe TestGenerator do
  describe 'String->String generator' do
    code = <<-eos
public class TulostusKolmesti {

    public static void main(String[] args) {
        String asia = "asia";
        tulosta(asia);
    }

    public static String tulosta(String input) {
        System.out.print(input);
        System.out.print(input);
        System.out.print(input);
        return input + input + input;
    }
}
    eos

    subject { TestGenerator.new }

    it 'is valid' do
      expect(subject).not_to be(nil)
    end

    it 'generates a test template that is a string' do
      io = { 1 => { input: 'asd', output: 'asdasdasd' },
             2 => { input: 'dsa', output: 'dsadsadsa' },
             3 => { input: 'dsas', output: 'dsasdsasdsas' } }

      expect(subject).to respond_to(:generate).with(3).arguments
      expect(subject.generate(:string_string, io, code)).to be_kind_of(String)
    end
  end
end
