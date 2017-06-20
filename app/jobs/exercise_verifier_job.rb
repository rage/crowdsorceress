# frozen_string_literal: true

class ExerciseVerifierJob < ApplicationJob
  require 'test_generator'
  require 'main_class_generator'
  require 'rest-client'
  require 'submission_status_channel'
  require 'application_controller'
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |_exception|
    puts 'RECORD NOT FOUND TROLOLOLO'
  end

  def perform(exercise)
    if exercise.is_a? String
      Rails.logger.warn('ExerciseVerifierJob called with a string! Silently aborting...')
      return
    end
    puts 'EXERCISE ID: ' + exercise.id.to_s
    puts 'Performing! omg'

    sleep 5
    # ApplicationController.set_current_status('in progress', 'Exercise saved to DB', 0.1, 'OK' => false, 'ERROR' => [])
    # SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[ApplicationController.get_current_status])
    SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[{'status' => 'in progress', 'message' => 'Exercise saved to DB.', 'progress' => 0.1, 'result' => {'OK' => false, 'ERROR' => ''}}])


    # create_tar(exercise)
    send_to_sandbox(exercise)
  end

  def create_tar(exercise)
    create_file('srcfile', exercise)
    create_file('testfile', exercise)

    `cd DoesThisEvenCompile/ && tar -cpf ../JavaPackage.tar * && cd ..`
  end

  def create_file(file_type, exercise)
    if file_type == 'srcfile'
      filename = 'DoesThisEvenCompile/src/DoesThisEvenCompile.java'
      generator = MainClassGenerator.new
    end
    if file_type == 'testfile'
      filename = 'DoesThisEvenCompile/test/DoesThisEvenCompileTest.java'
      generator = TestGenerator.new
    end

    file = File.new(filename, 'w+')
    file.close

    File.open(filename, 'w') do |f|
      f.write(generator.generate(exercise))
    end
  end

  def send_to_sandbox(exercise)
    create_tar(exercise)
    puts 'Sending to sandbox'
    # ApplicationController.set_current_status('in progress', 'Testing exercise in sandbox', 0.5, 'OK' => false, 'ERROR' => [])
    # SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[ApplicationController.get_current_status])
    SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[{'status' => 'in progress', 'message' => 'Testing exercise in sandbox', 'progress' => 0.5, 'result' => {'OK' => false, 'ERROR' => ''}}])


    File.open('JavaPackage.tar', 'r') do |tar_file|
      RestClient.post post_url, file: tar_file, notify: "https://22b6d68c.ngrok.io/exercises/#{exercise.id}/results", token: 'KISSA'
    end
    puts 'Sent to sandbox'
  end

  def post_url
    ENV['SANDBOX_BASE_URL'] + '/tasks.json'
  end
end
