module SessionsHelper
  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

   def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
   end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
