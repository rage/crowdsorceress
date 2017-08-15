# frozen_string_literal: true

class ExercisesController < ApplicationController
  before_action :set_exercise, only: %i[show update destroy results]
  before_action :ensure_signed_in!, only: %i[create]
  before_action :set_assignment, only: %i[create]

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

    if @exercise.in_progress?
      render json: { message: 'Exercise is already in progress', exercise: @exercise, status: 400 }
      return
    end

    @exercise.reset!

    @exercise.add_tags(params[:exercise][:tags])

    if @exercise.save
      ExerciseVerifierJob.perform_later @exercise
      @exercise.saved!
      MessageBroadcasterJob.perform_now(@exercise)

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
    if params[:token].include? 'MODEL'
      package_type = 'MODEL'
    elsif params[:token].include? 'STUB'
      package_type = 'STUB'
    end

    exercise = Exercise.find(params[:id])
    verify_secret_token(params[:token], exercise)
    test_output = JSON.parse(params[:test_output])
    exercise.handle_results(params[:status], test_output, package_type)
  end

  private

  def verify_secret_token(token, exercise)
    secret_token = if params[:token].include? 'MODEL'
                     token.gsub('MODEL', '')
                   else
                     token.gsub('STUB', '')
                   end

    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secrets[:secret_key_base])
    begin verifier.verify(secret_token)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      exercise.error_messages.push 'Tehtävän lähetys epäonnistui virheellisen avaimen vuoksi'
      exercise.error!
      MessageBroadcasterJob.perform_now(@exercise)
      raise InvalidSignature
    end
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
    params.require(:exercise).permit(:code, :assignment_id, :tags, testIO: %i[input output]).merge(description: desc_params)
  end
end
