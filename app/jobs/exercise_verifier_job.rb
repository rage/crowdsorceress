class ExerciseVerifierJob < ApplicationJob
  queue_as :default

  def perform(exercise)
    puts "Performing!"
  end
end
