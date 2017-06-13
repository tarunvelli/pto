# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  before_action :admin_user
  before_action :set_user, except: [:index]

  def index
    @users = User.all
    @ooo_config = OOOConfig.where('financial_year = ?',
                                  OOOConfig.financial_year).first
  end

  def show
    @leaves = @user.leaves.order('end_date DESC')
    @wfhs = @user.wfhs.order('end_date DESC')
    @ooo_period = OOOPeriod.new
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
