class UsersController < ApplicationController
  include CalendarHelper
  def show
    @user = User.find(params[:id])
    @activities = @user.activities
    @activities_by_date = @activities.group_by { |a| a[:start_time].to_date }
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
  end

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Cycling on Rails App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
