# frozen_string_literal: true

class User < ApplicationRecord
  has_many :exercises
  has_many :peer_reviews
end
