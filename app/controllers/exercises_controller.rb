# frozen_string_literal: true

class ExercisesController < ApplicationController
  before_action :set_exercise, only: %i[show edit update destroy results]
  before_action :ensure_signed_in!, only: %i[create]
  before_action :set_assignment, only: %i[create]

  # GET /exercises
  def index
    @exercises = Exercise.all.includes(:user)
  end

  # GET /exercises/1
  def show
  end

  # GET /exercises/new
  def new
    @exercise = Exercise.new
  end

  # GET /exercises/1/edit
  def edit
  end

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

  # POST /exercises/:id/results
  # TODO: what do
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

  # TODO: what do
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
