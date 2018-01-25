# session_controller
class SessionsController < ApplicationController
  include CrawlerHelper
  def new
    render 'sessions/new'
  end

  def create
    @user = User.new(user_params)
    if CrawlerHelper::AllowedCodes.include? @user.code
      if (agent = login(@user.code, @user.password))
        session[:user] = @user
        crawler = Crawler.instance
        crawler.agent = agent
        redirect_to new_reserve_path, :user => @user
      else
        puts 'FAIL'
      end
    end
    # puts @user
  end

  private

  def user_params
    params.require(:user).permit(:code, :password)
  end
end
