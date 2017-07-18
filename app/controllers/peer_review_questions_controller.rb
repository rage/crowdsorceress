# frozen_string_literal: true

class PeerReviewQuestionsController < ApplicationController
  before_action :set_peer_review_question, only: %i[show update destroy]

  # GET /peer_review_questions
  def index
    @peer_review_questions = PeerReviewQuestion.all

    render json: @peer_review_questions
  end

  # GET /peer_review_questions/1
  def show
    render json: @peer_review_question
  end

  # POST /peer_review_questions
  def create
    @peer_review_question = PeerReviewQuestion.new(peer_review_question_params)

    if @peer_review_question.save
      render json: @peer_review_question, status: :created, location: @peer_review_question
    else
      render json: @peer_review_question.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /peer_review_questions/1
  def update
    if @peer_review_question.update(peer_review_question_params)
      render json: @peer_review_question
    else
      render json: @peer_review_question.errors, status: :unprocessable_entity
    end
  end

  # DELETE /peer_review_questions/1
  def destroy
    @peer_review_question.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_peer_review_question
    @peer_review_question = PeerReviewQuestion.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def peer_review_question_params
    params.require(:peer_review_question).permit(:question, :exercise_type_id)
  end
end
