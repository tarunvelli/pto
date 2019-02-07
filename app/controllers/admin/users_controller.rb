# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  before_action :admin_user

  def index
    @financial_year = params[:financial_year] || OOOConfig.current_financial_year
    @ooo_config = OOOConfig.where('financial_year = ?', @financial_year).first
    @users = User.where('joining_date <= ?', FinancialYear.new(@financial_year).end_date)
    @financial_years = OOOConfig.all.order('financial_year DESC').pluck('financial_year')
    @current_quarter = FinancialQuarter.current_quarter
  end

  def show
    id = params[:select_user] || params[:id]
    @user = User.find(id)
    @leaves = @user.leaves.order('end_date DESC')
    @wfhs = @user.wfhs.order('end_date DESC')
    @ooo_period = OOOPeriod.new
    @financial_year = OOOConfig.current_financial_year
    @current_quarter = FinancialQuarter.current_quarter
    @users = User.all
  end

  def update
    id = params[:select_user] || params[:id]
    @user = User.find(id)
    if @user.update_attributes(user_params)
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
