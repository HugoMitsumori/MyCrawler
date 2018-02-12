# reservations Controller
class ReservationsController < ApplicationController
  include CrawlerHelper

  def index; end

  def new
    puts session[:user]
    @rooms = CrawlerHelper::CCSUL_ROOMS
  end

  def create
    success_reservations = []
    crawler = Crawler.instance
    @reservation = reservation_params
    @reservation[:rooms].delete '0'
    @reservation[:rooms].each do |room|
      page = crawler.reserve(
        'CCSUL', @reservation[:name], room, @reservation[:date],
        @reservation[:start_time], @reservation[:finish_time],
        @reservation[:members], @reservation[:organization], @reservation[:division]
      )
      next if page.nil? or page.forms.first.field_with(name: 'data').value != ''
      success_reservations << room
      sleep 2
    end
    respond_to do |format|
      format.js { render 'create', locals: { success: success_reservations } }
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
