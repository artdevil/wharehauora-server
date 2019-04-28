require 'rails_helper'

RSpec.describe MessageDecodeWorker, type: :worker do
  it { is_expected.to be_processed_in :message_decode }

  describe 'proccesing topic' do
    let(:home) { FactoryBot.create :home, gateway_mac_address: 'ABC1234567' }

    it "enqueues a v1 topic" do
      MessageDecodeWorker.perform_async("/sensors/wharehauora/#{home.id}/ABC123/1/1/0/0", 120)
      
      expect(MessageDecodeWorker.jobs.size).to eq(1)
    end

    it "enqueues a v2 topic" do
      MessageDecodeWorker.perform_async("/sensors/v2/#{home.gateway_mac_address}/ABC123/1/1/0/0", 120)
      
      expect(MessageDecodeWorker.jobs.size).to eq(1)
    end

    it "enqueues a v3 topic" do
      MessageDecodeWorker.perform_async("/sensors/v3/#{home.id}/#{home.gateway_mac_address}/ABC123/1/1/0/0", 120)
      
      expect(MessageDecodeWorker.jobs.size).to eq(1)
    end
  end
end
