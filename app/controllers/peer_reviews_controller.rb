# frozen_string_literal: true

class PeerReviewsController < ApplicationController
  before_action :set_peer_review, only: %i[show update destroy]
  before_action :ensure_signed_in!, only: %i[create]
  before_action :set_exercise, only: %i[create]

  # GET /peer_reviews
  def index
    @peer_reviews = PeerReview.all

    render json: @peer_reviews
  end

  # GET /peer_reviews/1
  def show
    render json: @peer_review
  end

  # POST /peer_reviews
  def create
    @peer_review = current_user.peer_reviews.find_or_initialize_by(exercise: @exercise, comment: params[:peer_review][:comment])

    PeerReview.transaction do
      if @peer_review.save
        render json: @peer_review, status: :created, location: @peer_review
        create_question_answers
      else
        render json: @peer_review.errors, status: :unprocessable_entity
      end
    end
  end

  def send_model_zip
    exercise = Exercise.find(params[:id])
    model_filename = Dir.entries(exercise_target_path(exercise)).find { |o| o.start_with?('ModelSolution') && o.end_with?('.zip') }
    send_zip template_zip_path(exercise, model_filename)
  end

  def send_stub_zip
    exercise = Exercise.find(params[:id])
    stub_filename = Dir.entries(exercise_target_path(exercise)).find { |o| o.start_with?('Stub') && o.end_with?('.zip') }
    send_zip template_zip_path(exercise, stub_filename)
  end

  def create_question_answers
    @reviews = params[:peer_review][:answers]

    @questions = @exercise.assignment.exercise_type.peer_review_questions

    @questions.each { |q| @peer_review.peer_review_question_answers.create! peer_review_question: q, grade: @reviews[q.question] }
  end

  # PATCH/PUT /peer_reviews/1
  def update
    if @peer_review.update(peer_review_params)
      render json: @peer_review
    else
      render json: @peer_review.errors, status: :unprocessable_entity
    end
  end

  # DELETE /peer_reviews/1
  def destroy
    @peer_review.destroy
  end

  # GET /peer_reviews/assignments/assignment_id/request_exercise
  def assign_exercise
    assignment = Assignment.find(params[:assignment_id])
    peer_review = PeerReview.new
    exercise = peer_review.draw_exercise(assignment)
    pr_questions = exercise.assignment.exercise_type.peer_review_questions

    render json: { exercise: exercise, peer_review_guestions: pr_questions }
  end

  private

  def send_zip(path)
    send_file path
  end

  def set_exercise
    @exercise = Exercise.find(params[:exercise][:exercise_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_peer_review
    @peer_review = PeerReview.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def peer_review_params
    params.require(:peer_review).permit(:comment, :answers)
    params.require(:exercise).permit(:exercise_id)
  end

  def exercise_target_path(exercise)
    Rails.root.join('submission_generation', 'packages', "assignment_#{exercise.assignment.id}", "exercise_#{exercise.id}")
  end

  def template_zip_path(exercise, zip_name)
    exercise_target_path(exercise).join(zip_name)
  end
end
