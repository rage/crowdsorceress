# frozen_string_literal: true

class ExercisesController < ApplicationController
  before_action :set_exercise, only: %i[show update destroy results]
  before_action :ensure_signed_in!, only: %i[create]
  before_action :set_assignment, only: :create

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
    @exercise = current_user.exercises.find_or_initialize_by(assignment: @assignment)
    @exercise.attributes = exercise_params

    return render_error_page(status: 409, text: 'Assignment already being processed') if @exercise.in_progress?

    @exercise.reset!

    if @exercise.save
      ExerciseVerifierJob.perform_later @exercise
      SubmissionStatusChannel.broadcast_to("SubmissionStatus_user:_#{current_user.id}_exercise:_#{@exercise.id}",
                                           JSON[{ 'status' => 'in progress', 'message' => 'Tehtävä tallennettu tietokantaan', 'progress' => 0.1,
                                                  'result' => { 'OK' => false, 'error' => @exercise.error_messages } }])
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

    exercise.handle_results(params[:status], test_output, params[:token])
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_exercise
    @exercise = Exercise.find(params[:id])
  end

  def set_assignment
    @assignment = Assignment.find(params[:exercise][:assignment_id])
  end

  # Only allow a trusted parameter "white list" through.
  def exercise_params
    # Allow any slate state for now...
    desc_params = params['exercise']['description'].permit!
    params.require(:exercise).permit(:code, :assignment_id, testIO: %i[input output]).merge(description: desc_params)
  end
end
