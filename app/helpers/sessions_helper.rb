# frozen_string_literal: true

module SessionsHelper
  def signed_in?
    # Sign out the user if the oauth token is getting close to expiry. User session expires 5 minutes prior to the oauth token expiry.
    current_user.present? && ((current_user.token_expires_at - (300)) > Time.now.to_i)
  end

  def current_user
    @current_user ||= User.where(id: session[:user_id]).first if session[:user_id]
  end

  def ensure_signed_in
    unless signed_in?
      session[:redirect_to] = request.fullpath
      redirect_to(root_path)
    end
  end
end
