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
      render json: { message: 'Exercise successfully created! :) :3' }, status: :created
      # SubmissionStatusChannel.broadcast_to("SubmissionStatus", data: "Exercise saved!") <- data JSON: { message: string, progress: number}

      SubmissionStatusChannel.broadcast_to("SubmissionStatus", data: "Exercise saved!")
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

  def results
    puts "I am " + params[:status]
    if !params[:exit_code].nil? then puts "with exit code " + params[:exit_code] end
    puts params[:vm_log]

    if params[:status] == 'finished' then status = true else status = false end
    SubmissionStatusChannel.broadcast_to("SubmissionStatus", data: { "status": status, "message": "Screaming externally", "progress": 0 })
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
