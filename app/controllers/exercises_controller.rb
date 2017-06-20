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
  # TODO method to find out the exercise type
  # TODO generate tests
  def create
    @exercise = current_user.exercises.new(exercise_params)

    if @exercise.save
      ExerciseVerifierJob.perform_later @exercise
      # SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[{ 'status' => 'In Progress', 'message' => 'Exercise saved to DB.', 'progress' => 0.1, 'result' => false }])

      render json: { message: 'Exercise successfully created! :) :3' }, status: :created
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
    set_current_status('in progress', 'Handling results', 0.666, 'OK' => false, 'ERROR' => [])
    SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[get_current_status])

    puts 'I am ' + params[:status]
    puts 'with exit code ' + params[:exit_code] unless params[:exit_code].nil?

    test_output = JSON.parse(params[:test_output])
    passed = test_output['status'] == 'PASSED' ? true : false

    set_current_status(params[:status], 'Valmista', 1, 'OK' => passed, 'ERROR' => test_output['testResults'])
    SubmissionStatusChannel.broadcast_to('SubmissionStatus', JSON[get_current_status])
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
