# frozen_string_literal: true

class ExercisesController < ApplicationController
  before_action :set_exercise, only: %i[show update destroy results]
  before_action :ensure_signed_in!, only: %i[create]

  # GET /exercises
  def index
    @exercises = Exercise.all

    render json: @exercises
  end

  # GET /exercises/1
  def show
    render json: @exercise
  end

  # POST /exercises
  def create
    @exercise = current_user.exercises.new(exercise_params)

    if @exercise.save
      ExerciseVerifierJob.perform_later @exercise

      SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[{ 'status' => 'in progress', 'message' => 'Tehtävä tallennettu tietokantaan',
                                                                      'progress' => 0.1, 'result' => { 'OK' => false, 'error' => @exercise.error_messages } }])
      @exercise.saved!

      render json: { message: 'Exercise successfully created! :) :3', exercise: @exercise }, status: :created
    else
      render json: @exercise.errors, status: :unprocessable_entity, message: 'Exercise not created. =( :F'
    end
  end

  # PATCH/PUT /exercises/1
  def update
    if @exercise.update(exercise_params)
      render json: @exercise
    else
      render json: @exercise.errors, status: :unprocessable_entity
    end
  end

  # DELETE /exercises/1
  def destroy
    @exercise.destroy
  end

  def sandbox_results
    # SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[{'status' => 'in progress', 'message' => 'Handling results',
    #                                                                'progress' => 0.666, 'result' => {'OK' => false, 'ERROR' => ''}}])

    exercise = Exercise.find(params[:id])

    puts 'I am ' + params[:status]
    puts 'with exit code ' + params[:exit_code] unless params[:exit_code].nil?

    test_output = JSON.parse(params[:test_output])
    passed = test_output['status'] == 'PASSED'
    compiled = test_output['status'] != 'COMPILE_FAILED'

    test_output['testResults'].each { |o| exercise.error_messages.push o['message'] }

    send_data_to_frontend(params[:status], passed, compiled, exercise, params[:token])

    params[:status] == 'finished' && passed && compiled ? exercise.finished! : exercise.error!
  end

  def send_data_to_frontend(status, passed, compiled, exercise, token)
    if token == 'KISSA_STUB' then message = 'Tehtäväpohjan tulokset: ' else message = 'Mallivastauksen tulokset: ' end

    if status == 'finished' && passed then message += 'Valmis'
    elsif status == 'finished' && compiled then message += 'Testit eivät menneet läpi'
    else
      message += 'Koodi ei kääntynyt'
      # byebug
      exercise.error_messages.push 'Compile failed'
    end

    SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[{ 'status' => status, 'message' => message, 'progress' => 1,
                                                                    'result' => { 'OK' => passed, 'ERROR' => exercise.error_messages } }])
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_exercise
    @exercise = Exercise.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def exercise_params
    # Allow any slate state for now...
    desc_params = params['exercise']['description'].permit!
    params.require(:exercise).permit(:code, :assignment_id, testIO: %i[input output]).merge(description: desc_params)
  end
end
