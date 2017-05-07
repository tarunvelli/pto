class UsersController < ApplicationController
  before_action :logged_in_user
  before_action :set_user

  def update
	  if @user.update_attributes(user_params)
	    flash[:success] = "Profile updated"
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
    params.require(:user).permit(:name, :email, :start_date,:total_leaves, :remaining_leaves)
  end
end
