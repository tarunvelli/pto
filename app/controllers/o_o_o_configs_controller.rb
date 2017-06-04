# frozen_string_literal: true

class OOOConfigsController < ApplicationController
  before_action :admin_user
  before_action :set_pto

  def update
    @ooo_config.no_of_pto = params[:no_of_pto]
    if @ooo_config.save
      flash[:success] = "configs are updated"
      redirect_to edit_ooo_configs_path
    else
      render 'edit'
    end
  end

  private

  def set_pto
    @ooo_config = OOOConfig.first
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
