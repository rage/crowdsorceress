# frozen_string_literal: true

class ExercisesController < ApplicationController
  before_action :set_exercise, only: %i[show update destroy]
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
    ExerciseVerifierJob.perform_later @exercise.code

    if @exercise.save
      render json: { message: 'Exercise successfully created! :) :3' }, status: :created
    else
      render json: @exercise.errors, status: :unprocessable_entity,  message: 'Exercise not created. =( :F'
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

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_exercise
    @exercise = Exercise.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def exercise_params
    params.require(:exercise).permit(:code, :description, :assignment_id, testIO: %i[input output])
  end
end
