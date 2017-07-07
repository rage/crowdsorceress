# frozen_string_literal: true

class PeerReview < ApplicationRecord
  belongs_to :user
  belongs_to :exercise
end
