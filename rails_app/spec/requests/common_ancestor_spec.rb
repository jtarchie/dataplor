# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CommonAncestors', type: :request do
  before do
    Node.from_csv(File.join(__dir__, '../assets/test.csv'))
  end

  context 'GET /common_ancestor' do
    context 'when the elements exist' do
      it 'returns a JSON response' do
        get '/common_ancestor', params: { a: 5_497_637, b: 2_820_230 }

        expect(response).to have_http_status(:success)

        payload = JSON.parse(response.body)
        expect(payload).to eq({
                                'depth' => 2,
                                'lowest_common_ancestor' => 125,
                                'root_id' => 130
                              })
      end
    end

    context 'when one of the elements does not exist' do
      it 'returns a JSON response' do
        get '/common_ancestor', params: { a: 9, b: 4_430_546 }

        expect(response).to have_http_status(:success)

        payload = JSON.parse(response.body)
        expect(payload).to eq({
                                'depth' => nil,
                                'lowest_common_ancestor' => nil,
                                'root_id' => nil
                              })
      end
    end

    context 'when both of the elements do not exist' do
      it 'returns a JSON response' do
        get '/common_ancestor', params: { a: 9, b: 101 }

        expect(response).to have_http_status(:success)

        payload = JSON.parse(response.body)
        expect(payload).to eq({
                                'depth' => nil,
                                'lowest_common_ancestor' => nil,
                                'root_id' => nil
                              })
      end
    end
  end
end
