# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'exercises/show', type: :view do
  before(:each) do
    @exercise = assign(:exercise, Exercise.create!(
                                    user_id: 2,
                                    code: 'MyText',
                                    assignment_id: 3,
                                    testIO: '',
                                    description: '',
                                    status: 4,
                                    error_messages: 'Error Messages',
                                    sandbox_results: 'MyText',
                                    peer_reviews_count: 5,
                                    model_solution: 'MyText',
                                    template: 'MyText'
    ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/Error Messages/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
  end
end
