# frozen_string_literal: true

module Api
  module V0
    class AssignmentsController < ApplicationController
      # GET /assignments/1
      def show
        render json: { assignment: @assignment, tags: Tag.recommended, template: @assignment.exercise_type.code_template }
      end
    end
  end
end
