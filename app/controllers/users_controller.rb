class UsersController < ApplicationController
  include CalendarHelper
  load_and_authorize_resource

  def show
    @user = User.find(params[:id])
    @activities = @user.activities
    @activities_by_date = @user.activities.group_by { |a| a[:start_time].to_date }
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

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'User was successfully deleted.' }
      format.json { head :no_content }
    end
  end
  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
