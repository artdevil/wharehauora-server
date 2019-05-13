# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::HomesController, type: :controller do
  render_views

  let!(:my_home)      { FactoryBot.create(:home, owner: user) }
  let!(:public_home)  { FactoryBot.create(:public_home)       }
  let!(:private_home) { FactoryBot.create(:home)              }

  let(:user) { FactoryBot.create :user }

  let(:application) { FactoryBot.create(:oauth_application) }
  let(:token) do
    FactoryBot.create(:oauth_access_token,
                      application: application,
                      resource_owner_id: my_home.owner.id)
  end

  let(:headers) do
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{token.token}"
    }
  end

  context 'OAuth authenticated ' do
    subject { JSON.parse(response.body) }

    describe 'GET #index' do
      shared_examples 'token belongs to home owner' do
        it { expect(my_home.owner.id).to eq(token.resource_owner_id) }
        it { expect(user.owned_homes).to include(my_home) }
      end

      shared_examples 'response includes my home' do
        describe 'response includes my home' do
          let(:matching_home) { subject['data'].select { |home| home['id'] == my_home.id }.first }

          it { expect(matching_home).to include('id' => my_home.id) }
          it { expect(matching_home).to include('name' => my_home.name) }
        end
      end
      shared_examples 'response includes public homes' do

        describe 'response includes public home' do
          
          let(:matching_home) { subject['data'].select { |home| home['id'] == public_home.id }.first }

          it { expect(matching_home).to include('id' => public_home.id) }
          it { expect(matching_home).to include('name' => public_home.name) }
        end
      end
      shared_examples 'response does not includes private homes' do
        describe 'response does not include private homes' do
          it { expect(subject['data'].any? { |home| home['id'] == private_home.id }).to eq(false) }
        end
      end

      describe 'home owner' do
        before do
          request.headers.merge! headers
          get :index
        end

        include_examples 'token belongs to home owner'

        it { expect(response).to have_http_status(:success) }
        include_examples 'response includes my home'
        include_examples 'response includes public homes'
        include_examples 'response does not includes private homes'
      end

      context 'invalid access token' do
        before { get :index, format: :json }

        it { expect(response).to have_http_status(401) }
      end
    end
  end

  describe '#create' do
    subject { JSON.parse(response.body)['data'] }

    let(:body) do
      {
        "name": 'home home home name',
        "gateway_mac_address": 'ABCDEF1010'
      }
    end
  
    before do
      request.headers.merge! headers
      post :create, { params: body }
    end

    it { expect(response).to have_http_status(:success) }
    it { expect(subject['name']).to eq 'home home home name' }
    it { expect(Home.last.owner.id).to eq my_home.owner.id }
  end

  describe '#update' do
    subject { JSON.parse(response.body)['data'] }

    let(:home_type) { FactoryBot.create :home_type }
    let(:body) do
      {
        "id": my_home.id,
        "name": 'new home name',
        "home_type_id": home_type.id
      }
    end

    before do
      request.headers.merge! headers
      patch :update, { params: body }
    end

    it { expect(Home.find(my_home.id).name).to eq 'new home name' }
    it { expect(response).to have_http_status(:success) }
    it { expect(subject['home_type_id']).to eq(home_type.id) }
  end
end
