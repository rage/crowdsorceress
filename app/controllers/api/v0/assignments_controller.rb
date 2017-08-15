# frozen_string_literal: true

module Api
  module V0
    class AssignmentsController < BaseController
      # GET /assignments/1
      def show
        @assignment = Assignment.find(params[:id])
        render json: { assignment: @assignment, tags: Tag.recommended, template: @assignment.exercise_type.code_template }
      end
    end
  end
end
