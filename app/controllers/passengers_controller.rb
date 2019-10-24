# frozen_string_literal: true

class PassengersController < ApplicationController
  before_action :find_passenger,
                only: %i[show edit update destroy toggle_archive]
  before_action :access_control, only: %i[destroy archived toggle_archive]

  def archived
    @passengers = Passenger.archived
  end

  def toggle_archive
    if @passenger.archived?
      @passenger.active!
    else
      # skip validations on archival
      @passenger.update_attribute(:active_status, 'archived')
    end
    redirect_to passengers_url, notice: 'Passenger successfully updated'
  end

  def check_existing
    @passenger = Passenger.find_by(spire: params[:spire_id])
    return unless @passenger.present?
    render partial: 'check_existing'
  end

  def new
    @passenger = Passenger.new
    @doctors_note = DoctorsNote.new
  end

  def edit
    @doctors_note = @passenger.doctors_note || DoctorsNote.new
  end

  # rubocop:disable Style/GuardClause
  def index
    @passengers = Passenger.active.order :name
    @filters = []
    filter = params[:filter]
    if %w[permanent temporary].include? filter
      @passengers = @passengers.send filter.downcase
      @filters << filter
    else @filters << 'all'
    end
    if params[:print].present?
      pdf = PassengersPDF.new(@passengers, @filters)
      name = "#{@filters.map(&:capitalize).join(' ')} Passengers #{Date.today}"
      send_data pdf.render, filename: name,
                            type: 'application/pdf',
                            disposition: :inline
    end
  end
  # rubocop:enable Style/GuardClause

  def create
    @passenger = Passenger.new(passenger_params)
    @passenger.registered_by = @current_user
    if @passenger.save
      redirect_to @passenger, notice: 'Passenger was successfully created.'
    else render :new
    end
  end

  def update
    @passenger.assign_attributes passenger_params
    if @passenger.save
      redirect_to @passenger, notice: 'Passenger was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @passenger.destroy
    redirect_to passengers_url, notice: 'Passenger was successfully destroyed.'
  end

  private

  def passenger_params
    base_passenger_params
      .then { |p| restrict_admin p }
      .then { |p| disallow_nonexpiring_note p }
  end

  def base_passenger_params
    passenger_params = params.require(:passenger)
      .permit(:name, :address, :email, :phone, :wheelchair, :mobility_device_id,
              :permanent, :note, :spire, :status, :has_brochure,
              :registered_with_disability_services,
              doctors_note_attributes: %i[expiration_date])
    passenger_params[:active_status] = params[:passenger][:active]
    passenger_params
  end

  def disallow_nonexpiring_note(permitted_params)
    note_params = permitted_params[:doctors_note_attributes]
    return permitted_params unless note_params.try(:[], :expiration_date).blank?

    permitted_params.except :doctors_note_attributes
  end

  def restrict_admin(permitted_params)
    return permitted_params if @current_user.admin?

    permitted_params.except :permanent
  end

  def find_passenger
    @passenger = Passenger.find(params[:id])
  end
end
