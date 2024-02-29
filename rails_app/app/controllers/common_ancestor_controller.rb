# frozen_string_literal: true

class CommonAncestorController < ApplicationController
  def show
    result = Node.common_ancestor(params[:a], params[:b])

    render json: {
      root_id: result&.root_id,
      lowest_common_ancestor: result&.lowest&.id,
      depth: result&.lowest&.depth
    }
  end
end
