# frozen_string_literal: true

class PeerReviewsController < ApplicationController
  before_action :set_peer_review, only: %i[show edit update destroy]
  before_action :ensure_signed_in!, only: %i[create]
  before_action :set_exercise, only: %i[create]

  # GET /peer_reviews
  def index
    @peer_reviews = PeerReview.all
  end

  # GET /peer_reviews/1
  def show; end

  # GET /peer_reviews/new
  def new
    @peer_review = PeerReview.new
  end

  # GET /peer_reviews/1/edit
  def edit; end

  # POST /peer_reviews
  # TODO: what do
  def create
    @peer_review = PeerReview.new(peer_review_params)

    if @peer_review.save
      redirect_to @peer_review, notice: 'Peer review successfully created.'
    else
      render :new, notice: 'Peer review creation failed.'
    end
  end

  # PATCH/PUT /peer_reviews/1
  def update
    if @peer_review.update(peer_review_params)
      redirect_to @peer_review, notice: 'Peer review successfully updated.'
    else
      render :edit, notice: 'Peer review update failed.'
    end
  end

  # DELETE /peer_reviews/1
  def destroy
    @peer_review.destroy
    redirect_to peer_reviews_url, notice: 'Peer review was successfully destroyed.'
  end

  private

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
    params.require(:exercise).permit(:exercise_id, :tags)
  end

  def exercise_target_path(exercise)
    Rails.root.join('submission_generation', 'packages', "assignment_#{exercise.assignment.id}", "exercise_#{exercise.id}")
  end

  def template_zip_path(exercise, zip_name)
    exercise_target_path(exercise).join(zip_name)
  end
end
