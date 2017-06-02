class ExerciseTypesController < ApplicationController
  before_action :set_exercise_type, only: %i[show update destroy]

  # GET /exercise_types
  def index
    @exercise_types = ExerciseType.all

    render json: @exercise_types
  end

  # GET /exercise_types/1
  def show
    render json: @exercise_type
  end

  # POST /exercise_types
  def create
    @exercise_type = ExerciseType.new(exercise_type_params)

    if @exercise_type.save
      render json: @exercise_type, status: :created, location: @exercise_type
    else
      render json: @exercise_type.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /exercise_types/1
  def update
    if @exercise_type.update(exercise_type_params)
      render json: @exercise_type
    else
      render json: @exercise_type.errors, status: :unprocessable_entity
    end
  end

  # DELETE /exercise_types/1
  def destroy
    @exercise_type.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_exercise_type
    @exercise_type = ExerciseType.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def exercise_type_params
    params.require(:exercise_type).permit(:name, :test_template)
  end
end
