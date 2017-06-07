require 'rails_helper'
require 'test_generator'

RSpec.describe TestGenerator do
  describe "String->String generator" do
    subject { TestGenerator.new() }

    it 'is valid' do
      expect(subject).not_to be(nil)
    end

    it 'generates a test template that is a string' do
      expect(subject).to respond_to(:generate).with(1).argument
      expect(subject.generate(:string_string)).to be_kind_of(String)
    end
    
  end
end
