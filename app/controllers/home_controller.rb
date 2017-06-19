# frozen_string_literal: true

class HomeController < ApplicationController
  def show
    redirect_to oooperiods_path if signed_in?
  end
end
