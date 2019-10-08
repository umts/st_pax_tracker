# frozen_string_literal: true

require 'rails_helper'

describe 'Passenger Management' do
  context 'as an admin' do
    before :each do
      @user = create :user, :admin
      @passenger = create :passenger, name: 'Foo Bar'
      when_current_user_is(@user)
    end
    context 'creating a new passenger successfully' do
      it 'creates the passenger' do
        date = 2.days.since.strftime '%Y-%m-%d'
        visit passengers_path
        click_link 'Add New Passenger'
        fill_in 'Passenger Name', with: 'Foo Bar'
        fill_in 'Email', with: 'foobar@invalid.com'
        fill_in 'Passenger Spire', with: '12345678@umass.edu'
        fill_in 'Expiration Date', with: date
        click_button 'Submit'
        expect(page).to have_text 'Passenger was successfully created.'
      end
    end
    context 'editing an existing passenger successfully' do
      it 'updates the passenger' do
        create :doctors_note, passenger: @passenger
        visit passengers_path
        click_link 'Edit'
        fill_in 'Passenger Name', with: 'Bar Foo'
        click_button 'Submit'
        expect(page).to have_text 'Passenger was successfully updated.'
      end
    end
    context 'deleting an existing passenger successfully' do
      it 'deletes the passenger' do
        visit passengers_path
        click_button 'Delete'
        expect(page).to have_text 'Passenger was successfully destroyed.'
      end
    end
    context 'archiving a passenger successfully' do
      it 'archives the passenger' do
        visit passengers_path
        click_button 'Archive'
        expect(page).to have_text 'Passenger successfully updated'
        expect(@passenger.reload).to be_archived
      end
    end
    context 'creating a temporary passenger without a doctors note' do
      it 'creates the passenger' do
        visit new_passenger_path
        fill_in 'Passenger Name', with: 'Jane Fonda'
        fill_in 'Passenger Spire', with: '12345678@umass.edu'
        fill_in 'Email', with: 'jfonda@umass.edu'
        select 'Student', from: 'UMass Status'
        click_button 'Submit'
        expect(page).to have_text 'Passenger was successfully created.'
      end
    end
  end
  context 'as a dispatcher' do
    before :each do
      @user = create :user
      @passenger = create :passenger, name: 'Foo Bar'
      when_current_user_is(@user)
    end
    context 'creating a new passenger successfully' do
      it 'creates the passenger' do
        date = 2.days.since.strftime '%Y-%m-%d'
        visit passengers_path
        click_link 'Add New Passenger'
        fill_in 'Passenger Name', with: 'Foo Bar'
        fill_in 'Email', with: 'foobar@invalid.com'
        fill_in 'Expiration Date', with: date
        fill_in 'Passenger Spire', with: '12345678@umass.edu'
        click_button 'Submit'
        expect(page).to have_text 'Passenger was successfully created.'
      end
    end
    context 'editing an existing passenger successfully' do
      it 'updates the passenger' do
        create :doctors_note, passenger: @passenger
        visit passengers_path
        click_link 'Edit'
        fill_in 'Passenger Name', with: 'Bar Foo'
        click_button 'Submit'
        expect(page).to have_text 'Passenger was successfully updated.'
      end
    end
    context 'wanting to delete a passenger' do
      it 'does not have a button to do so' do
        visit passengers_path
        expect(page).not_to have_button 'Delete'
      end
    end
  end
end
