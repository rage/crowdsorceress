# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:course) { FactoryGirl.create(:course) }
  let!(:assignment) do
    FactoryGirl.create(:assignment,
                       course: course,
                       exercise_type: FactoryGirl.create(:exercise_type, testing_type: 2, test_template: '%<tests>s'),
                       part: 'osa1',
                       peer_review_count: 3)
  end

  describe 'when counting points' do
    context 'for user with no points' do
      it 'gives correct points' do
        points = user.get_points(course)
        expect(points).to eq([{ group: 'osa1', progress: 0.0, n_points: 0, max_points: 4 }])
      end
    end

    context 'for user whose done exercises' do
      let!(:exercise) do
        FactoryGirl.create(:exercise,
                           assignment: assignment,
                           unit_tests: [{ test_name: 'test', assertion_type: 'contains', test_code: 'asfsdfsd' }],
                           user: user, status: 'finished')
      end

      it 'gives correct points' do
        points = user.get_points(course)
        expect(points).to eq([{ group: 'osa1', progress: 0.25, n_points: 1, max_points: 4 }])
      end
    end

    context 'for user whose done exercises and peer reviews' do
      let!(:exercise) do
        FactoryGirl.create(:exercise,
                           assignment: assignment,
                           unit_tests: [{ test_name: 'test', assertion_type: 'contains', test_code: 'asfsdfsd' }],
                           user: user, status: 'finished')
      end

      let!(:exercise2) do
        FactoryGirl.create(:exercise,
                           assignment: assignment,
                           unit_tests: [{ test_name: 'test', assertion_type: 'contains', test_code: 'asfsdfsd' }],
                           status: 'finished')
      end

      let!(:peer_review) do
        FactoryGirl.create(:peer_review, exercise: exercise, user: user)
      end

      let!(:peer_review2) do
        FactoryGirl.create(:peer_review, exercise: exercise2, user: user)
      end

      it 'gives correct points' do
        points = user.get_points(course)
        expect(points).to eq([{ group: 'osa1', progress: 0.75, n_points: 3, max_points: 4 }])
      end
    end
  end
end
