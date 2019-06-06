# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeViewer, type: :model do
  let(:home) { FactoryBot.create :home }
  let(:user) { FactoryBot.create :user }
  let(:home_viewer) { FactoryBot.build :home_viewer, home: home }

  describe 'assigned user to home' do
    describe 'with existing user' do
      before do
        home_viewer.email = user.email
      end

      it { expect(home_viewer.assigned_user_to_home).to eq true }
    end

    describe 'with invite user' do
      describe 'and valid email' do
        before do
          home_viewer.email = 'abc@hello.com'
        end
  
        it { expect(home_viewer.assigned_user_to_home).to eq true }
      end

      describe 'and invalid email' do
        before do
          home_viewer.email = 'abc'
        end
  
        it { expect(home_viewer.assigned_user_to_home).to eq false }
      end
    end

    describe 'with existing user in home viewer' do
      before do
        FactoryBot.create(:home_viewer, home: home, user: user)
        home_viewer.email = user.email
        home_viewer.assigned_user_to_home
      end

      it { expect(home_viewer.errors.present?).to eq true }
      it { expect(home_viewer.errors[:user]).to eq ['already assign as home viewer'] }
    end
  end
end
