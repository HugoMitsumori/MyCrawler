# Reserves Controller
class ReservesController < ApplicationController
  include CrawlerHelper

  def index 
  end

  def new
    puts session[:user]
    @rooms = CrawlerHelper::CCSUL_ROOMS
  end

  def create
    success_reserves = []
    crawler = Crawler.instance
    @reserve = reserve_params
    @reserve[:rooms].split.each do |room|
      page = crawler.reserve(
        'CCSUL', @reserve[:name], room, @reserve[:date],
        @reserve[:start_time], @reserve[:finish_time],
        @reserve[:members], @reserve[:organization], @reserve[:division]
      )
      unless page.nil? or page.forms.first.field_with(name: 'data').value != ''
        success_reserves << room
        sleep 2
      end
    end
    respond_to do |format|
      format.js { render 'create', locals: { success: success_reserves } }
    end
  end

  private

  def reserve_params
    params.require(:reserve).permit(
      :name, :date, :start_time, :finish_time, :rooms, :members, :organization, :division
    )
  end
end
