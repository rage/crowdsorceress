# frozen_string_literal: true

class ExercisesController < ApplicationController
  before_action :set_exercise, only: %i[show edit update destroy]
  before_action :set_assignment, only: %i[create]

  # GET /exercises
  def index
    @exercises = search_exercises
    @exercises_count = @exercises.count
    @finished_count = @exercises.where(status: 'finished').count
    @error_count = @exercises.where(status: 'error').count
    @timeout_count = @exercises.where(status: 'sandbox_timeout').count

    @exercises = @exercises.page(params[:page])

    @exercise_count_msg = ''
    if params[:assignment_search_term].present?
      @exercise_count_msg += " for assignment #{params[:assignment_search_term]}"
    end
    if params[:status_search_term].present?
      @exercise_count_msg += " with status #{params[:status_search_term]}"
    end
    @exercise_count_msg = ' in total' if @exercise_count_msg.empty?
  end

  # GET /exercises/1
  def show
    @tags = @exercise.tags
  end

  # GET /exercises/new
  def new
    @exercise = Exercise.new
  end

  # GET /exercises/1/edit
  def edit; end

  # POST /exercises
  # TODO: what do
  def create
    @exercise = Exercise.new(exercise_params)

    if @exercise.save
      redirect_to @exercise, notice: 'Exercise was successfully created.'
    else
      render :new, notice: 'Exercise creation failed.'
    end
  end

  # PATCH/PUT /exercises/1
  def update
    if @exercise.update(exercise_params)
      redirect_to @exercise, notice: 'Exercise was successfully updated.'
    else
      render :edit, notice: 'Exercise update failed.'
    end
  end

  # DELETE /exercises/1
  def destroy
    @exercise.destroy
    redirect_to exercises_url, notice: 'Exercise was successfully destroyed.'
  end

  private

  def search_exercises
    exercises = Exercise.all
    if params[:assignment_search_term].present?
      exercises = exercises.where(assignment_id: params[:assignment_search_term])
    end
    if params[:status_search_term].present?
      exercises = exercises.where(status: params[:status_search_term])
    end
    exercises.includes(:user)
  end

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
    params.require(:exercise).permit(:user_id, :code, :assignment_id, :tags, unit_tests: %i[test_name assertion_type test_code],
                                                                             testIO: %i[input output],
                                                                             assignment_search_term: :assignment_search_term,
                                                                             status_search_term: :status_search_term).merge(description: desc_params)
  end
end
