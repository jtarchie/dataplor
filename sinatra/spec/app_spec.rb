# frozen_string_literal: true

require_relative '../lib/app'
require 'rack/test'
require 'climate_control'

RSpec.describe 'web app' do
  include Rack::Test::Methods

  def app
    App
  end

  def with_modified_env(options = {}, &block)
    ClimateControl.modify(options, &block)
  end

  context 'GET /common_ancestor' do
    context 'when the elements exist' do
      it 'returns a JSON response' do
        with_modified_env NODE_CSV: File.join(__dir__, 'test.csv') do
          get '/common_ancestor?a=5497637&b=2820230'

          expect(last_response).to be_ok

          payload = JSON.parse(last_response.body)
          expect(payload).to eq({
                                  'depth' => 2,
                                  'lowest_common_ancestor' => 125,
                                  'root_id' => 130
                                })
        end
      end
    end

    context 'when one of the elements does not exist' do
      it 'returns a JSON response' do
        with_modified_env NODE_CSV: File.join(__dir__, 'test.csv') do
          get '/common_ancestor?a=9&b=4430546'

          expect(last_response).to be_ok

          payload = JSON.parse(last_response.body)
          expect(payload).to eq({
                                  'depth' => nil,
                                  'lowest_common_ancestor' => nil,
                                  'root_id' => nil
                                })
        end
      end
    end
  end
end
