# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  before_action :admin_user

  def index
    @ooo_config = OOOConfig.get_config_from_financial_year(financial_year: params[:financial_year])
    @financial_year = @ooo_config.financial_year
    @users = User.includes(:leaves, :wfhs).where('joining_date <= ?', @ooo_config.end_date)
    @financial_years = OOOConfig.all.order('financial_year DESC').pluck('financial_year')
    @current_quarter = FinancialQuarter.current_quarter
  end

  def show
    id = params[:select_user] || params[:id]
    @ooo_config = OOOConfig.get_config_from_financial_year(financial_year: params[:financial_year])
    @financial_year = @ooo_config.financial_year
    @user = User.find(id)
    @leaves = @user.leaves.where('end_date >= ? and start_date <= ?', @ooo_config.start_date, @ooo_config.end_date)
                   .order('end_date DESC')
    @wfhs = @user.wfhs.where('end_date >= ? and start_date <= ?', @ooo_config.start_date, @ooo_config.end_date)
                 .order('end_date DESC')
    @ooo_period = OOOPeriod.new
    @current_quarter = FinancialQuarter.current_quarter
    @users = User.all
    @financial_years = OOOConfig.all.order('financial_year DESC').pluck('financial_year')
  end

  def update
    id = params[:select_user] || params[:id]
    @user = User.find(id)
    if @user.update(user_params)
      # TODO: cancel events from google calendar on user deactivation
      flash[:success] = "#{@user.name} updated Successfully"
      redirect_to admin_users_url
    else
      render 'index'
    end
  end

  private

  def user_params
    params.require(:user).permit(:active)
  end
end
