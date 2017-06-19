# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(request.env['omniauth.auth'])
    session[:user_id] = user.id
    if current_user.remaining_leaves
      redirect_to oooperiods_path
    else
      redirect_to edit_user_path(user.id)
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
