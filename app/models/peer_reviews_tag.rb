# frozen_string_literal: true

class PeerReviewsTag < ApplicationRecord
  belongs_to :peer_review
  belongs_to :tag # counter_cache: true
end
