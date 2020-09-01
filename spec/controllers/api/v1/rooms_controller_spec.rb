# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RoomsController, type: :controller do
  render_views

  let(:room_type) { FactoryBot.create :room_type, min_temperature: 10, max_temperature: 30 }
  let(:room)      { FactoryBot.create :public_room, room_type: room_type                   }
  let(:home)      { room.home                                                              }
  let(:owner)     { home.owner                                                             }
  let(:admin)     { FactoryBot.create :admin                                               }
  let(:otheruser) { FactoryBot.create :user                                                }

  let(:whanau) do
    whanau = FactoryBot.create :user
    room.home.users << whanau
    whanau
  end

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

  # do nothing normally. Contexts below can add readings
  let(:create_readings) {}

  describe '#show' do
    let(:params) { { id: room.id, home_id: home.id } }

    shared_examples 'can see summaries' do
      it { expect(response).to have_http_status(:success) }
    end
    shared_examples 'cannot see summaries' do
      it { expect(response).not_to have_http_status(:success) }
    end

    shared_examples 'returns expected readings' do
      subject { JSON.parse(response.body) }

      let(:temperature_response) { subject['data']['temperature']          }
      let(:humidity_response)    { subject['data']['humidity']             }
      let(:dewpoint_response)    { subject['data']['dewpoint']             }
      let(:rating_response)     { subject['data']['rating']  }

      it { expect(subject['data']).to include('name' => room.name) }

      describe 'room too hot' do
        let(:create_readings) { FactoryBot.create :temperature_reading, value: 101.1, room: room }

        it { expect(temperature_response).to include('value' => '101.1°C') }
      end

      describe 'room too cold' do
        let(:create_readings) { FactoryBot.create :temperature_reading, value: 3.1, room: room }

        it { expect(temperature_response).to include('value' => '3.1°C') }
      end

      describe 'room just right' do
        let(:create_readings) { FactoryBot.create :temperature_reading, value: 20.5, room: room }

        it { expect(temperature_response).to include('value' => '20.5°C') }
      end
    end

    describe 'When room is in a public home' do
      before do
        create_readings
        request.headers.merge! headers
        get :show, params: params
      end

      let(:room) { FactoryBot.create :public_room, room_type: room_type }

      shared_examples 'check permissions' do
        describe 'and user is not logged in ' do
          let(:user) { nil }

          include_examples 'can see summaries'
        end

        describe 'and user is logged in ' do
          describe 'as the whare owner' do
            let(:user) { owner }

            include_examples 'can see summaries'
            include_examples 'returns expected readings'
          end

          describe 'as whanau' do
            let(:user) { whanau }

            include_examples 'can see summaries'
            include_examples 'returns expected readings'
          end

          describe 'as admin' do
            let(:user) { admin }

            include_examples 'can see summaries'
            include_examples 'returns expected readings'
          end

          describe 'as a user from another home' do
            let(:user) { otheruser }

            include_examples 'can see summaries'
            include_examples 'returns expected readings'
          end
        end
      end
    end

    describe 'when room is private' do
      let(:room)      { FactoryBot.create :room, room_type: room_type    }
      let!(:readings) { FactoryBot.create_list :reading, 100, room: room }

      before do
        create_readings
        request.headers.merge! headers
        get :show, params: params
      end

      describe 'and user is not logged in ' do
        let(:user) { nil }

        include_examples 'cannot see summaries'
      end

      describe 'and user is logged in ' do
        describe 'as the whare owner' do
          let(:user) { owner }

          include_examples 'can see summaries'
          include_examples 'returns expected readings'
        end

        describe 'as whanau' do
          let(:user) { whanau }

          include_examples 'can see summaries'
          include_examples 'returns expected readings'
        end

        describe 'as admin' do
          let(:user) { admin }

          include_examples 'can see summaries'
          include_examples 'returns expected readings'
        end

        describe 'but user is not allowed to view the room' do
          let(:user) { otheruser }

          include_examples 'cannot see summaries'
        end
      end
    end
  end

  describe '#update' do
    describe 'with valid data' do
      subject { JSON.parse(response.body)['data'] }
      let(:user) { owner }

      let(:body) do
        {
          'id': room.to_param,
          'home_id': home.id,
          'name': 'new room name'
        }
      end

      before do
        request.headers.merge! headers
        patch :update, **{ params: body }
      end

      it { expect(Room.find(room.id).name).to eq 'new room name' }
      it { expect(response).to have_http_status(:success) }
    end

    describe 'with invalid data' do
      subject { JSON.parse(response.body) }
      let(:user) { owner }

      let(:body) do
        {
          'id': room.to_param,
          'home_id': home.id,
          'name': ''
        }
      end

      before do
        request.headers.merge! headers
        patch :update, **{ params: body }
      end

      it { expect(subject['success']).to eq false }
    end

    describe 'with invalid room id' do
      subject { JSON.parse(response.body) }
      let(:user) { owner }

      let(:body) do
        {
          'id': 1000,
          'home_id': home.id,
          'name': ''
        }
      end

      before do
        request.headers.merge! headers
        patch :update, **{ params: body }
      end

      it { expect(subject['success']).to eq false }
    end
  end
end
