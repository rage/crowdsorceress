# frozen_string_literal: true

module Api
  module V0
    class AssignmentsController < BaseController
      # GET /assignments/1
      def show
        @assignment = Assignment.find(params[:id])
        template = !@assignment.exercise_type.code_template.nil? ? @assignment.exercise_type.code_template : ''
        render json: { assignment: @assignment, tags: Tag.recommended, template: template }
      end
    end
  end
end
