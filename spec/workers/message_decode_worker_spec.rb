require 'rails_helper'

RSpec.describe MessageDecodeWorker, type: :worker do
  it { is_expected.to be_processed_in :message_decode }

  describe 'proccesing topic' do
    describe 'with invalid home' do
      # https://stackoverflow.com/questions/10998160/rspec-how-to-test-rails-logger-message-expectations
      
      it "not enqueues a v1 topic" do
        expect(Sidekiq::Logging.logger).to receive(:info).with("Couldn't find Home")

        MessageDecodeWorker.new.perform("/sensors/v3/1234/ABC1234567/ABC123/1/1/0/0", 120)
      end

      it "not enqueues a v2 topic" do
        expect(Sidekiq::Logging.logger).to receive(:info).with("Couldn't find Home")

        MessageDecodeWorker.new.perform("/sensors/v2/ABC1234567/ABC123/1/1/0/0", 120)
      end

      it "not enqueues a v3 topic" do
        expect(Sidekiq::Logging.logger).to receive(:info).with("Couldn't find Home")

        MessageDecodeWorker.new.perform("/sensors/v3/1234/ABC1234567/ABC123/1/1/0/0", 120)
      end
    end

    describe 'with valid home' do
      let(:home) { FactoryBot.create :home, gateway_mac_address: 'ABC1234567' }

      describe 'perform async' do
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

      describe 'perform' do
        it "enqueues a v1 topic" do
          MessageDecodeWorker.new.perform("/sensors/wharehauora/#{home.id}/ABC123/1/1/0/0", 120)
          
          expect(home.sensors.present?).to eq(true)
        end

        it "enqueues a v2 topic" do
          MessageDecodeWorker.new.perform("/sensors/v2/#{home.gateway_mac_address}/ABC123/1/1/0/0", 120)
          
          expect(home.sensors.present?).to eq(true)
        end

        it "enqueues a v3 topic" do
          MessageDecodeWorker.new.perform("/sensors/v3/#{home.id}/#{home.gateway_mac_address}/ABC123/1/1/0/0", 120)
          
          expect(home.sensors.present?).to eq(true)
        end
      end
    end
  end
end
