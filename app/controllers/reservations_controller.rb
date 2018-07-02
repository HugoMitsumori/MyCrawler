# reservations Controller
class ReservationsController < ApplicationController
  include CrawlerHelper
  before_action :verify_session

  def index; end

  def choose
    @centers = Crawler::CENTER_CODES.keys
  end

  def new
    @place = params[:center]
    @rooms = Crawler.instance.rooms(@place)
    @page = Crawler.instance.reservations_page(@place)
  end

  def create
    params = reservation_params
    rooms = params[:rooms] - ['0']
    base_reservation = Reservation.new(params.except(:rooms, :date, :start_time))
    base_reservation.datetime = "#{params[:date]} #{params[:start_time]}"
    base_reservation.token = User.new(session[:user]).encrypted
    if (base_reservation.datetime.to_date - Date.today).to_i > CrawlerHelper::MAX_FORWARD[params[:place]]
      base_reservation.status = 'Reserva Futura'
    else
      base_reservation.status = 'Processando Reserva'
    end
    reservations = []
    rooms.each do |room|
      reservation = base_reservation.dup
      reservation.room = CrawlerHelper::CCSUL_ROOMS.invert[room]
      reservation.save
      ReservationJob.perform_now(reservation) if reservation.status == 'Processando Reserva'
      reservations << reservation
    end

    redirect_to results_path, reservations: reservations
  end

  def results
    @reservations = params[:reservations]
  end

  private

  def reservation_params
    params.require(:reservation).permit(
      :name, :date, :start_time, :finish_time,
      :members, :organization, :division, :place, rooms: []
    )
  end

  def verify_session
    redirect_to root_path unless session[:user].present?
  end
end
