class ExercisesController < ApplicationController
  before_action :set_exercise, only: %i[show update destroy]

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
  # TODO metodi exercise typen selvittämiseen (find_type) 
  # ts. selvitä mikä on exercise type
  def create
    # ensure_signed_in!
    if current_user
    @exercise = Exercise.new(exercise_params)

    if @exercise.save
      render json: @exercise, status: :created, location: @exercise
    else
      render json: @exercise.errors, status: :unprocessable_entity
    end
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
    params[:exercise] = JSON.parse(params[:exercise])
    params.require(:exercise).permit(:user_id, :code, :description, :input, :output, :type_id)
    # byebug
end
end
