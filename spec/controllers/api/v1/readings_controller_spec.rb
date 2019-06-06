# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ReadingsController, type: :controller do
  render_views

  let!(:reading) { FactoryBot.create(:reading, room: room, created_at: '2018-09-16 05:56:00 UTC') }
  let(:user)     { room.home.owner                                                                }
  let(:room)     { FactoryBot.create :room                                                        }
  let(:home)     { room.home }

  let(:application) { FactoryBot.create(:oauth_application) }
  let(:token) do
    FactoryBot.create(:oauth_access_token,
                      application: application,
                      resource_owner_id: user.try(:id))
  end

  let(:headers) do
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{token.token}"
    }
  end

  context 'OAuth authenticated ' do
    subject(:data) { JSON.parse(response.body)['data'] }

    describe 'GET #index' do

      before do
        request.headers.merge! headers
        get :index, params: { controller: 'api/v1/readings', room_id: room.id, home_id: home.id, key: 'temperature' }
      end

      describe '#index' do
        let(:week_start) { reading.created_at.to_s }

        it { expect(response.status).to eq 200 }
        it {
          expect(data.first).to eq ({ '2018-09-16 05:56:00 UTC' => reading.value }) 
        }
      end
    end
  end
end
