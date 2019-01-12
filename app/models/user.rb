# frozen_string_literal: true

class User < ApplicationRecord
  has_many :exercises
  has_many :peer_reviews

  def get_points(course)
    assignments_on_course = Assignment.where(course_id: course.id)
    users_exercises = Exercise.where(user_id: id)
    parts = parts(assignments_on_course)

    points_by_part(parts, assignments_on_course, users_exercises)
  end

  def parts(assignments_on_course)
    parts = []
    assignments_on_course.each do |assignment|
      parts.push assignment.part unless parts.include? assignment.part
    end
    parts
  end

  def points_by_part(parts, assignments_on_course, users_exercises)
    points_by_part = []

    parts.each do |part|
      points = 0
      max_points = 0

      assignments_on_course.where(part: part).find_each do |assignment|
        exercise = users_exercises.find_by(assignment_id: assignment.id)
        points += 1 if !exercise.nil? && exercise.finished?
        max_points += 1
      end

      progress = (points.to_f / max_points.to_f * 100).floor.to_f / 100

      points_by_part.push(part: part, progress: progress, n_points: points, max_points: max_points)
    end

    points_by_part
  end
end
