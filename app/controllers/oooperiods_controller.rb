# frozen_string_literal: true

class OooperiodsController < ApplicationController
  before_action :ensure_signed_in
  before_action :set_ooo_period, except: [:create]

  def index
    @total_leaves = current_user.leaves.order('end_date DESC')
    @editable_leaves = current_user.leaves.where('end_date > ?', Date.current)
    @total_wfhs = current_user.wfhs.order('end_date DESC')
    @editable_wfhs = current_user.wfhs.where('end_date > ?', Date.current)
  end

  def create
    @ooo_period = current_user.o_o_o_periods.build(ooo_period_params)
    if @ooo_period.save
      flash[:success] = 'OOO Period form Submitted!'
      redirect_to oooperiods_url
    else
      render 'new'
    end
  end

  def update
    if @ooo_period.update_attributes(ooo_period_params)
      flash[:success] = 'OOO Period updated Successfully'
      redirect_to oooperiods_url
    else
      render 'edit'
    end
  end

  def destroy
    return unless @ooo_period.destroy
    flash[:success] = 'OOO Period Cancelled'
    redirect_to oooperiods_url
  end

  def number_of_days
    @days = OOOPeriod.business_days_between(
      params[:start_date].to_date,
      params[:end_date].to_date
    )
    render json: @days
  end

  private

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
