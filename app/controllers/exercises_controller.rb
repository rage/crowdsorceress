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
    @exercise.sandbox_results = { status: '', message: '', passed: true, model_results_received: false, stub_results_received: false }

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

  # POST /exercises/:id/results
  def sandbox_results
    exercise = Exercise.find(params[:id])
    test_output = JSON.parse(params[:test_output])

    # Push test results into exercise's error messages
    test_output['testResults'].each do |o|
      exercise.error_messages.push o['message']
    end

    # Handle sending results to frontend in exercise model
    exercise.handle_results(params[:status], test_output['status'] == 'PASSED', test_output['status'] != 'COMPILE_FAILED', params[:token])
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
