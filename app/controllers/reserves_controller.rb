# Reserves Controller
class ReservesController < ApplicationController
  include CrawlerHelper
  def new
    puts session[:user]
    @rooms = CrawlerHelper::CCSUL_ROOMS
  end

  def create
    crawler = Crawler.instance
    @reserve = reserve_params
    @reserve[:rooms].split.each do |room|
      page = crawler.reserve(
        'CCSUL', @reserve[:name], room, @reserve[:date],
        @reserve[:start_time], @reserve[:finish_time], @reserve[:members]
      )
      unless page.nil?
        puts page.inspect
        sleep 2
      end
    end
  end

  private

  def reserve_params
    params.require(:reserve).permit(
      :name, :date, :start_time, :finish_time, :rooms, :members
    )
  end
end
