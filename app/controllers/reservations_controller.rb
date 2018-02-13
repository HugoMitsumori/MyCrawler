# reservations Controller
class ReservationsController < ApplicationController
  include CrawlerHelper

  def index; end

  def new
    puts session[:user]
    @center = params[:center]
    @rooms = Crawler.instance.rooms(@center)
  end

  def create
    success_rooms = []
    crawler = Crawler.instance
    @reservation = Reservation.new(reservation_params)
    @reservation.rooms.each do |room|
      page = crawler.reserve(room, @reservation)
      puts page.inspect
      next if page.nil? or page.forms.first.field_with(name: 'data').value != ''
      success_rooms << crawler.room_name(@reservation.center, room)
      sleep 2
    end
    respond_to do |format|
      format.js { render 'create', locals: { success: success_rooms } }
    end
  end

  def choose
    @centers = Crawler::CENTER_CODES.keys
  end

  private

  def reservation_params
    params.require(:reservation).permit(
      :name, :date, :start_time, :finish_time,
      :members, :organization, :division, :center, rooms: []
    )
  end
end
