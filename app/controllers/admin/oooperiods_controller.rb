# frozen_string_literal: true

class Admin::OooperiodsController < ApplicationController
  before_action :admin_user
  before_action :load_user
  before_action :set_ooo_period, except: [:create]

  def create
    @ooo_period = @user.ooo_periods.build(ooo_period_params)
    if @ooo_period.save
      flash[:success] = "#{@ooo_period.type} applied!"
      redirect_to admin_user_url(@user)
    else
      render 'new'
    end
  end

  def update
    if @ooo_period.update_attributes(ooo_period_params)
      flash[:success] = "#{@ooo_period.type} updated Successfully"
      redirect_to admin_user_url(@user)
    else
      render 'edit'
    end
  end

  def destroy
    return unless @ooo_period.destroy
    flash[:success] = "#{@ooo_period.type} Cancelled"
    redirect_to admin_user_url(@user)
  end

  private

  def load_user
    @user = User.find(params[:user_id])
  end

  def set_ooo_period
    @ooo_period = params[:id].present? ? ooo_period : OOOPeriod.new
  end

  def ooo_period
    OOOPeriod.find(params[:id])
  end

  def ooo_period_params
    params.require(:ooo_period).permit(:start_date, :end_date, :type)
  end
end
