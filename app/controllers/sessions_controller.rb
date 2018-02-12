# session_controller
class SessionsController < ApplicationController
  include CrawlerHelper
  def new
    render 'sessions/new'
  end

  def create
    @user = User.new(user_params)
    if CrawlerHelper::ALLOWED_CODES.include? @user.code
      crawler = Crawler.instance
      if crawler.login(@user.code, @user.password)
        session[:user] = @user
        redirect_to new_reservation_path, user: @user
      else
        puts 'FAIL'
      end
    end
    gon.logado = 'sim'
  end

  private

  def user_params
    params.require(:user).permit(:code, :password)
  end
end
