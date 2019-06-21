# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  before_action :admin_user

  def index
    @financial_year = params[:financial_year] || OOOConfig.current_financial_year
    @ooo_config = OOOConfig.includes(:holidays).where('financial_year = ?', @financial_year).first
    @users = User.includes(:leaves, :wfhs).where('joining_date <= ?', FinancialYear.new(@financial_year).end_date)
    @financial_years = OOOConfig.all.order('financial_year DESC').pluck('financial_year')
    @current_quarter = FinancialQuarter.current_quarter
  end

  def show
    id = params[:select_user] || params[:id]
    @financial_year = params[:financial_year] || OOOConfig.current_financial_year
    @user = User.find(id)
    @fy = FinancialYear.new(@financial_year)
    @leaves = @user.leaves.where('end_date >= ? and start_date <= ?', @fy.start_date, @fy.end_date)
                   .order('end_date DESC')
    @wfhs = @user.wfhs.where('end_date >= ? and start_date <= ?', @fy.start_date, @fy.end_date)
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
