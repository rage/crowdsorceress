# frozen_string_literal: true

class PeerReviewsController < ApplicationController
  before_action :set_peer_review, only: %i[show update destroy]

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
    @peer_review = PeerReview.new(peer_review_params)

    if @peer_review.save
      render json: @peer_review, status: :created, location: @peer_review
    else
      render json: @peer_review.errors, status: :unprocessable_entity
    end
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

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_peer_review
    @peer_review = PeerReview.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def peer_review_params
    params.require(:peer_review).permit(:user_id, :exercise_id, :comment)
  end
end
