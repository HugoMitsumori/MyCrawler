# session_controller
class SessionsController < ApplicationController
  include CrawlerHelper

  def new; end

  def create
    @user = User.new(user_params)
    if Crawler.instance.login(@user.code, @user.password)
      session[:user] = @user
      redirect_to reservations_choose_path, user: @user
    else
      respond_to { |format| format.js { render 'fail' } }
    end
    gon.logado = 'sim'
  end

  private

  def user_params
    params.require(:user).permit(:code, :password)
  end
end
