class ReservesController < ApplicationController
  include CrawlerHelper
  def new
    puts session[:user]
    agent = Crawler.instance.agent
  end
end
