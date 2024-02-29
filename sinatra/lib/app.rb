# frozen_string_literal: true

require 'json'
require 'sinatra'
require_relative 'node'

class App < Sinatra::Base
  before do
    @node ||= Node.from_csv(ENV.fetch('NODE_CSV'))
  end

  get '/common_ancestor' do
    result = @node.common_ancestor(params['a'], params['b'])

    content_type :json

    {
      root_id: result&.root_id,
      lowest_common_ancestor: result&.lowest&.id,
      depth: result&.lowest&.depth
    }.to_json
  end
end
