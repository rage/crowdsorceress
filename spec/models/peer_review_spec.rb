# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PeerReview, type: :model do
  let(:assignment) { FactoryGirl.create(:assignment) }
  let(:user) { FactoryGirl.create(:user, administrator: false) }

  describe 'when drawing a new exercise' do
    it 'returns an empty array when drawing 0' do
      2.times { FactoryGirl.create(:exercise, status: 'finished', assignment: assignment) }
      exercises = PeerReview.new.draw_exercises(assignment, user, 0)

      expect(exercises).to eq([])
    end

    it 'draws a given amount of exercises' do
      5.times { FactoryGirl.create(:exercise, status: 'finished', assignment: assignment, user: FactoryGirl.create(:user)) }

      exercises = PeerReview.new.draw_exercises(assignment, user, 3)

      expect(exercises.length).to eq(3)
    end

    it 'gives user\'s own exercise for self-evaluation' do
      FactoryGirl.create(:exercise, status: 'finished', assignment: assignment, user: user)

      own_exercise = PeerReview.new.own_exercise(assignment, user)

      expect(own_exercise.user_id).to eq(user.id)
    end

    it 'returns an empty array when drawing a negative number' do
      exercises = PeerReview.new.draw_exercises(assignment, user, -666)

      expect(exercises).to eq([])
    end

    it 'doesn\'t draw the same exercise twice' do
      FactoryGirl.create(:exercise, status: 'finished', assignment: assignment)

      exercises = PeerReview.new.draw_exercises(assignment, user, 2)

      expect(exercises.uniq.length).to eq(exercises.length)
    end

    it 'doesn\'t draw unfinished exercises' do
      FactoryGirl.create(:exercise, status: 'saved', assignment: assignment)
      FactoryGirl.create(:exercise, status: 'error', assignment: assignment)
      FactoryGirl.create(:exercise, status: 'testing_template', assignment: assignment)
      FactoryGirl.create(:exercise, status: 'status_undefined', assignment: assignment)
      FactoryGirl.create(:exercise, status: 'testing_model_solution', assignment: assignment)
      FactoryGirl.create(:exercise, status: 'half_done', assignment: assignment)
      FactoryGirl.create(:exercise, status: 'sandbox_timeout', assignment: assignment)

      exercises = PeerReview.new.draw_exercises(assignment, user, 2)

      expect(exercises.all? { |e| e.status != 'finished' }).to be true
    end

    it 'draws the exercises with the least peer reviews' do
      ex1 = FactoryGirl.create(:exercise, peer_reviews_count: 1, status: 'finished', assignment: assignment, user: user)
      ex2 = FactoryGirl.create(:exercise, peer_reviews_count: 0, user: FactoryGirl.create(:user), status: 'finished', assignment: assignment)
      FactoryGirl.create(:exercise, peer_reviews_count: 2, user: FactoryGirl.create(:user), status: 'finished', assignment: assignment)

      exercises = PeerReview.new.draw_exercises(assignment, user, 2)

      expect(exercises).to contain_exactly(ex1, ex2)
    end

    it 'doesn\'t draw admins\' exercises' do
      admin = FactoryGirl.create(:user, administrator: true)

      ex1 = FactoryGirl.create(:exercise, peer_reviews_count: 0, user: admin, status: 'finished', assignment: assignment)
      FactoryGirl.create(:exercise, peer_reviews_count: 0, user: admin, status: 'finished', assignment: assignment)
      FactoryGirl.create(:exercise, peer_reviews_count: 0, user: user, status: 'finished', assignment: assignment)
      FactoryGirl.create(:exercise, peer_reviews_count: 0, user: User.new, status: 'finished', assignment: assignment)

      FactoryGirl.create(:exercise, peer_reviews_count: 0, user: User.new, status: 'finished', assignment: assignment)

      exercises = PeerReview.new.draw_exercises(assignment, user, 2)

      expect(exercises.count).to eq(2)
      expect(exercises.any? { |e| e == ex1 }).to be false
    end
  end
end
