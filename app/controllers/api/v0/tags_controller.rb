# frozen_string_literal: true

module Api
  module V0
    class TagsController < ApplicationController
      # POST /tags
      def create
        @tag = Tag.new(tag_params)

        if @tag.save
          render json: @tag, status: :created, location: @tag
        else
          render json: @tag.errors, status: :unprocessable_entity
        end
      end
    end
  end
end
