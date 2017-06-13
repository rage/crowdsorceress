# frozen_string_literal: true

class ExerciseVerifierJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |_exception|
    puts 'RECORD NOT FOUND TROLOLOLO'
  end

  before_perform do
    puts 'HEIPPA'
  end

  def perform(exercise)
    puts 'EXERCISE ID: ' + exercise.id.to_s
    puts 'Performing! omg'

    create_file(exercise)
    Minitar.pack(exercise.id.to_s, Zlib::GzipWriter.new(File.open(exercise.id.to_s + '.tgz', 'wb')))

    #tarball
  end

  def create_file(exercise)
    file = File.new(exercise.id.to_s, 'w+')
    file.close

    File.open(exercise.id.to_s, 'w') do |file|
      file.write(exercise.code)
    end

    puts File.read(exercise.id.to_s)
    file
  end
end
