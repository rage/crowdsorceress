# frozen_string_literal: true

class PeerReviewQuestionsController < ApplicationController
  before_action :set_peer_review_question, only: %i[show edit update destroy]

  # GET /peer_review_questions
  def index
    @peer_review_questions = PeerReviewQuestion.all
  end

  # GET /peer_review_questions/1
  def show
  end

  # GET /peer_review_questions/new
  def new
    @peer_review_question = PeerReviewQuestion.new
  end

  # GET /peer_review_questions/1/edit
  def edit; end

  # POST /peer_review_questions
  def create
    @peer_review_question = PeerReviewQuestion.new(peer_review_question_params)

    if @peer_review_question.save
      redirect_to @peer_review_question, notice: 'Peer review question successfully created.'
    else
      render :new, notice: 'Peer review question creation failed.'
    end
  end

  # PATCH/PUT /peer_review_questions/1
  def update
    if @peer_review_question.update(peer_review_question_params)
      redirect_to @peer_review_question, notice: 'Peer review question successfully updated.'
    else
      render :edit, notice: 'Peer review question update failed.'
    end
  end

  # DELETE /peer_review_questions/1
  def destroy
    @peer_review_question.destroy
    redirect_to peer_review_questions_url, notice: 'Peer review question successfully destroyed.'
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
