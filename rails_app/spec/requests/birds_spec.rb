# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Birds', type: :request do
  describe 'GET /birds' do
    before do
      Node.from_csv(File.join(__dir__, '../assets/test.csv'))

      Node.all.each_with_index do |node, index|
        Bird.create!(id: index + 1, node_id: node.id)
      end
    end

    it 'returns the list of a bird' do
      get '/birds', params: { node_ids: [130] }

      expect(response).to have_http_status(200)

      payload = JSON.parse(response.body)
      expect(payload['bird_ids'].length).to eq 5
      expect(payload['bird_ids']).to eq [1, 2, 3, 4, 5]
    end

    it 'returns a list of birds across multiple nodes' do
      get '/birds', params: { node_ids: [2_820_230] }

      expect(response).to have_http_status(200)

      payload = JSON.parse(response.body)
      expect(payload['bird_ids'].length).to eq 1
      expect(payload['bird_ids']).to eq [3]
    end

    it 'returns an empty list when no birds are found' do
      get '/birds', params: { node_ids: ['sadf'] }

      expect(response).to have_http_status(200)

      payload = JSON.parse(response.body)
      expect(payload['bird_ids'].length).to eq 0
      expect(payload['bird_ids']).to eq []
    end
  end
end
