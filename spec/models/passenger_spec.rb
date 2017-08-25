# frozen_string_literal: true

require 'rails_helper'

describe Passenger do
  before :each do
    @passenger = create :passenger
  end

  describe 'expiration_display' do
    context 'permanent passenger' do
      it "returns nil" do
        @passenger.update permanent: true
        expect(@passenger.expiration_display).to be nil
      end
    end
    context 'temporary passenger' do
      it 'returns the expiration date' do
        date = 14.days.since
        create :doctors_note, passenger: @passenger, expiration_date: date
        expect(@passenger.expiration_display).to eql date.strftime('%m/%d/%Y')
      end
    end
  end

  describe 'temporary?' do
    it 'gets the not of permanent' do
      expect(@passenger.temporary?).to be true
    end
  end

  describe 'self.deactivate_expired_doc_note' do
    it 'deactivates the expired passenger' do
      create :doctors_note, passenger: @passenger,
                            expiration_date: 4.days.ago
      @passenger.update active: true
      Passenger.deactivate_expired_doc_note
      @passenger.reload
      expect(@passenger.active).to be false
    end
  end
end
