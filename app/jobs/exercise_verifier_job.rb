class ExerciseVerifierJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    puts 'RECORD NOT FOUND TROLOLOLO'
  end

  def perform(exercise)
    puts 'EXERCISE ID:'
    puts exercise.id
    puts "Performing!"
  end
end
