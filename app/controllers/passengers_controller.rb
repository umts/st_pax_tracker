class PassengersController < ApplicationController
  before_action :find_passenger, only: [:show, :edit, :update, :destroy]

  def new
    @passenger = Passenger.new
  end

  def index
    @permanent = params[:filter] == 'permanent'
    @temporary = params[:filter] == 'temporary'
    @all = params[:filter] == 'all'
    @search_term = params[:search]
    @passengers = Passenger.order :name
    @passengers = @passengers.search(@search_term) if @search_term.present?
    @passengers = @passengers.permanent if @permanent.present?
    @passengers = @passengers.temporary if @temporary.present?
  end

  def show
  end

  def edit
  end

  def create
    @passenger = Passenger.new(passenger_params)
    if @passenger.save
      redirect_to @passenger, notice: 'Passenger was successfully created.'
    else
      render :new
    end
  end

  def update
    if @passenger.update(passenger_params)
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
    params.require(:passenger).permit(:name, :address, :email, :phone,
      :wheelchair, :active, :permanent, :expiration, :note)
  end

  def find_passenger
    @passenger = Passenger.find(params[:id])
  end
end
