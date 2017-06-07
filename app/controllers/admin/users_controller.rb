class Admin::UsersController < ApplicationController
  before_action :admin_user
  before_action :set_user, except: [:index]

  def index
    @users = User.all
  end

  def show
    @leaves = @user.leaves.order("end_date DESC")
    @leave = Leave.new
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

end
