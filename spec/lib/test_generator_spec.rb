require 'rails_helper'
require 'test_generator'

RSpec.describe TestGenerator do
  describe "String->String generator" do
    subject { TestGenerator.new(:string_string) }

    it 'is valid' do
      expect(subject).not_to be(nil)
    end
  end
end
