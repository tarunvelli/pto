# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :ensure_signed_in
  before_action :admin_user, only: [:index]
  before_action :set_user, except: [:index]

  def update
    if @user.update_attributes(user_params)
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

  def user_params
    params.require(:user).permit(
      :name, :email, :joining_date,
      :total_leaves, :remaining_leaves
    )
  end
end
