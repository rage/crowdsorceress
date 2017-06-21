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

      SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[{ 'status' => 'in progress', 'message' => 'Exercise saved to DB', 'progress' => 0.1, 'result' => { 'OK' => false, 'error' => '' } }])
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
    # SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[{'status' => 'in progress', 'message' => 'Handling results', 'progress' => 0.666, 'result' => {'OK' => false, 'ERROR' => ''}}])

    puts 'I am ' + params[:status]
    puts 'with exit code ' + params[:exit_code] unless params[:exit_code].nil?

    test_output = JSON.parse(params[:test_output])
    passed = test_output['status'] == 'PASSED' ? true : false
    error_messages = []
    test_output['testResults'].each{ |o| error_messages.push o['message'] }
    # set_current_status(params[:status], 'Valmista', 1, 'OK' => passed, 'ERROR' => test_output['testResults'])
    # SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[get_current_status])
    SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[{'status' => params[:status], 'message' => 'Valmis', 'progress' => 1, 'result' => {'OK' => passed, 'ERROR' => error_messages}}])
    params[:status] == 'finished' && passed ? Exercise.find(params[:id]).finished! : Exercise.find(params[:id]).error!
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
