class PtosController < ApplicationController
	before_action :admin_user

   def edit
   	 @no_of_pto = APP_CONFIG[:number_of_pto]
   end

   private

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end

