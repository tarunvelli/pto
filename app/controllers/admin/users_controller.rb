# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  before_action :admin_user
  before_action :set_user, except: [:index]

  def index
    @financial_year = params[:financial_year] || OOOConfig.financial_year
    @ooo_config = OOOConfig.where('financial_year = ?', @financial_year).first
    @users = User.where('joining_date <= ?',
                        Date.new(@financial_year.split('-')[1].to_i, 3, -1))
    @financial_years = OOOConfig.all.order('financial_year DESC')
                                .pluck('financial_year')
  end

  def show
    @leaves = @user.leaves.order('end_date DESC')
    @wfhs = @user.wfhs.order('end_date DESC')
    @ooo_period = OOOPeriod.new
    @financial_year = OOOConfig.financial_year
    @current_quarter = @user.current_quarter
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
