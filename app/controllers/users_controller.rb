# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :ensure_signed_in
  before_action :set_user
  before_action :check_user

  def update
    if @user.update(user_params)
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def check_user
    redirect_to current_user if current_user != @user
  end

  def user_params
    params.require(:user).permit(:name, :joining_date)
  end
end
