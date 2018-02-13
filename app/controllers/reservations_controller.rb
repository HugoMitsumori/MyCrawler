# reservations Controller
class ReservationsController < ApplicationController
  include CrawlerHelper

  def index; end

  def new
    puts session[:user]
    Crawler.instance.capacity 'INTERLAGOS'
    @rooms = CrawlerHelper::CCSUL_ROOMS
  end

  def create
    success_rooms = []
    crawler = Crawler.instance
    @reservation = Reservation.new(reservation_params)
    @reservation.rooms.each do |room|
      page = crawler.reserve('CCSUL', room, @reservation)
      puts page.inspect
      next if page.nil? or page.forms.first.field_with(name: 'data').value != ''
      success_rooms << room
      sleep 2
    end
    respond_to do |format|
      format.js { render 'create', locals: { success: success_rooms } }
    end
  end

  private

  def reservation_params
    params.require(:reservation).permit(
      :name, :date, :start_time, :finish_time,
      :members, :organization, :division, rooms: []
    )
  end
end
