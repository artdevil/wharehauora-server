require 'rails_helper'

RSpec.describe Gateway::ConfigController, type: :controller do
  describe 'GET config for a gateway' do
    before do
      ENV['CLOUDMQTT_URL'] = 'mqtt://bob:bobpassword@qwerty.mqttsomewhere.nz:12345/hey'
      ENV['MQTT_SSL_PORT'] = '54321'
      post :show, id: 'abc', format: :text
    end
    it { expect(response).to have_http_status(:success) }
    it { expect(response.body).to eq('qwerty.mqttsomewhere.nz:54321') }
    it { expect(response.content_type).to eq 'text/plain'}
  end
end
