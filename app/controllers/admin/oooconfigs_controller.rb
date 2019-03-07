# frozen_string_literal: true

class Admin::OooconfigsController < ApplicationController
  before_action :admin_user
  before_action :set_ooo_config, except: [:create]

  def create
    @ooo_config = OOOConfig.new(ooo_config_params)
    if @ooo_config.save
      flash[:success] = "Added Configs for #{@ooo_config.financial_year} financial year"
      redirect_to admin_users_path
    else
      render 'new'
    end
  end

  def update
    if @ooo_config.update(ooo_config_params)
      flash[:success] = 'configs are updated'
      redirect_to admin_users_path
    else
      render 'edit'
    end
  end

  private

  def set_ooo_config
    @ooo_config = params[:id].present? ? OOOConfig.find(params[:id]) : OOOConfig.new
  end

  def ooo_config_params
    params.require(:ooo_config).permit(
      :financial_year,
      :leaves_count,
      :wfhs_count,
      :wfh_headsup_hours,
      :wfh_penalty_coefficient
    )
  end
end
