# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  include SessionsHelper
  before_action :set_paper_trail_whodunnit
end
