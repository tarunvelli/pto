# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  before_action :admin_user
  before_action :set_user, except: [:index]

  def index
    financial_year = params[:financial_year] || OOOConfig.financial_year
    @ooo_config = OOOConfig.where('financial_year = ?', financial_year).first
    @users_info = OooPeriodsInfo.get_user_info_by_fy(financial_year)
    @financial_years = OOOConfig.all.order('financial_year DESC').pluck('financial_year')
  end

  def show
    @leaves = @user.leaves.order('end_date DESC')
    @wfhs = @user.wfhs.order('end_date DESC')
    @ooo_period = OOOPeriod.new
    @current_financial_year = OOOConfig.financial_year
    @current_quarter = "q#{@user.send(:current_quarter)}"
    @ooo_periods_info = @user.ooo_periods_infos.where(
      'financial_year = ? ', @current_financial_year).first
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
