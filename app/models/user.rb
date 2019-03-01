# frozen_string_literal: true

class User < ApplicationRecord
  has_many :exercises
  has_many :peer_reviews

  def get_points(course)
    assignments_on_course = Assignment.where(course_id: course.id)
    users_exercises = Exercise.where(user_id: id)
    users_peer_reviews = PeerReview.where(user_id: id)
    parts = parts(assignments_on_course)

    points_by_part(parts, assignments_on_course, users_exercises, users_peer_reviews)
  end

  def parts(assignments_on_course)
    parts = []
    assignments_on_course.each do |assignment|
      parts.push assignment.part unless parts.include? assignment.part
    end
    parts
  end

  def points_by_part(parts, assignments_on_course, users_exercises, users_peer_reviews)
    points_by_part = []

    parts.each do |part|
      points_per_exercise = points_per_exercise(assignments_on_course, part, users_exercises, users_peer_reviews)
      points = points_per_exercise[:points]
      max_points = points_per_exercise[:max_points]

      progress = progress(points, max_points)

      points_by_part.push(group: part, progress: progress, n_points: points, max_points: max_points)
    end

    points_by_part
  end

  def points_per_exercise(assignments_on_course, part, users_exercises, users_peer_reviews)
    points = 0
    max_points = 0

    assignments_on_course.where(part: part).find_each do |assignment|
      exercise = users_exercises.find_by(assignment_id: assignment.id)
      review = users_peer_reviews.select { |p| p.exercise.assignment_id == assignment.id }
      points += 1 if !exercise.nil? && (exercise.finished? || !assignment.show_results_to_user)
      points += review.count > assignment.peer_review_count ? assignment.peer_review_count : review.count
      max_points += 1 + assignment.peer_review_count
    end

    { points: points, max_points: max_points }
  end

  def progress(points, max_points)
    (points.to_f / max_points.to_f * 100).floor.to_f / 100
  end
end
