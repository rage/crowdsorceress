# frozen_string_literal: true

class AssignmentsController < ApplicationController
  before_action :set_assignment, only: %i[show edit update destroy]

  # GET /assignments
  def index
    @assignments = Assignment.all
  end

  # GET /assignments/1
  def show
    @exercises = Exercise.page(params[:page]).per(25).where(assignment_id: params[:id])
    @exercises_count = Exercise.where(assignment_id: params[:id]).count
    @finished_count = Exercise.where(assignment_id: params[:id], status: 'finished').count
    @error_count = Exercise.where(assignment_id: params[:id], status: 'error').count
    @timeout_count = Exercise.where(assignment_id: params[:id], status: 'sandbox_timeout').count
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
  end

  # GET /assignments/1/edit
  def edit; end

  # POST /assignments
  def create
    @assignment = Assignment.new(assignment_params)

    if @assignment.save
      redirect_to @assignment, notice: 'Assignment was successfully created.'
    else
      render :new, notice: 'Assignment creation failed.'
    end
  end

  # PATCH/PUT /assignments/1
  def update
    if @assignment.update(assignment_params)
      redirect_to @assignment, notice: 'Assignment was successfully updated.'
    else
      render :edit, notice: 'Assignment update failed.'
    end
  end

  # DELETE /assignments/1
  def destroy
    @assignment.destroy
    redirect_to assignments_url, notice: 'Assignment was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_assignment
    @assignment = Assignment.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def assignment_params
    params.require(:assignment).permit(:description, :exercise_type_id, :course_id, :part, :show_results_to_user, :mandatory_tags, :peer_review_count)
  end
end
