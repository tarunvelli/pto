class UsersController < ApplicationController
  before_action :logged_in_user
  before_action :set_user

	def edit
	end

	def update
	    params[:user][:total_leaves] = params[:user][:remaining_leaves] = number_of_leaves
	    if @user.update_attributes(user_params)
	      flash[:success] = "Profile updated"
	      redirect_to @user
	    else
	      render 'edit'
	    end
    end

    def show
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :start_date,:total_leaves, :remaining_leaves)
    end

    def number_of_leaves
       leaves_count = 0
    	 current_year = Date.current.year
    	 if (current_year == params[:user][:start_date].to_date.year)
    	  	leaves_count = ((Date.new(current_year,12,31) - 
            params[:user][:start_date].to_date) * APP_CONFIG[:number_of_pto] / 365 ).ceil
         else
         	leaves_count = APP_CONFIG[:number_of_pto]
       end
       leaves_count
    end
end
