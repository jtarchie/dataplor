# frozen_string_literal: true

class BirdsController < ApplicationController
  def index
    bird_ids = Bird.ids_from_nodes(params[:node_ids].map(&:to_i))

    render json: {
      bird_ids:
    }
  end
end
