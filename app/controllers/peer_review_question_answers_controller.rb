# frozen_string_literal: true

class PeerReviewQuestionAnswersController < ApplicationController
  before_action :set_peer_review_question_answer, only: %i[show update destroy]

  # GET /peer_review_question_answers
  def index
    @peer_review_question_answers = PeerReviewQuestionAnswer.all

    render json: @peer_review_question_answers
  end

  # GET /peer_review_question_answers/1
  def show
    render json: @peer_review_question_answer
  end

  # POST /peer_review_question_answers
  def create
    @peer_review_question_answer = PeerReviewQuestionAnswer.new(peer_review_question_answer_params)

    if @peer_review_question_answer.save
      render json: @peer_review_question_answer, status: :created, location: @peer_review_question_answer
    else
      render json: @peer_review_question_answer.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /peer_review_question_answers/1
  def update
    if @peer_review_question_answer.update(peer_review_question_answer_params)
      render json: @peer_review_question_answer
    else
      render json: @peer_review_question_answer.errors, status: :unprocessable_entity
    end
  end

  # DELETE /peer_review_question_answers/1
  def destroy
    @peer_review_question_answer.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_peer_review_question_answer
    @peer_review_question_answer = PeerReviewQuestionAnswer.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def peer_review_question_answer_params
    params.require(:peer_review_question_answer).permit(:grade, :peer_review_id, :peer_review_question_id)
  end
end
