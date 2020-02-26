# frozen_string_literal: true

class OooperiodsController < ApplicationController
  before_action :ensure_signed_in
  before_action :set_ooo_period, except: [:create]
  before_action :choose_ooo_period_class, only: [:update]

  def index
    @total_leaves = current_user.leaves.order('end_date DESC')
    @editable_leaves = current_user.leaves.where('end_date >= ?', Date.current)
    @total_wfhs = current_user.wfhs.order('end_date DESC')
    @editable_wfhs = current_user.wfhs.where('end_date >= ?', Date.current)
    @financial_year = OOOConfig.current_financial_year
    @current_quarter = FinancialQuarter.current_quarter
    @holidays = OOOConfig.find_by(financial_year: @financial_year).holidays
  end

  def create
    @ooo_period = current_user.ooo_periods.build(ooo_period_params)
    if @ooo_period.save
      flash[:success] = "#{@ooo_period.type} applied!"
      redirect_to oooperiods_url
    else
      @financial_year = OOOConfig.current_financial_year
      @current_quarter = FinancialQuarter.current_quarter
      render 'new'
    end
  end

  def bydate
    @date = params[:sect_date].present? ? params[:sect_date].values.join('/').to_date : Date.today
    @leaves = Leave.where('start_date <= ? AND end_date >= ?', @date, @date)
    @wfhs = Wfh.where('start_date <= ? AND end_date >= ?', @date, @date)
  end

  def edit
    @financial_year = OOOConfig.current_financial_year
    @current_quarter = FinancialQuarter.current_quarter
  end

  def update
    if @ooo_period.update(ooo_period_params)
      flash[:success] = "#{@ooo_period.type} updated Successfully"
      redirect_to oooperiods_url
    else
      render 'edit'
    end
  end

  def destroy
    return unless @ooo_period.destroy

    flash[:success] = "#{@ooo_period.type} Cancelled"
    redirect_to oooperiods_url
  end

  private

  def set_ooo_period
    @ooo_period = params[:id].present? ? OOOPeriod.find(params[:id]) : OOOPeriod.new
  end

  def ooo_period_params
    params.require(:ooo_period).permit(:start_date, :end_date, :type)
  end

  def choose_ooo_period_class
    return unless @ooo_period.type != ooo_period_params[:type]

    @ooo_period = @ooo_period.becomes(ooo_period_params[:type].constantize)
  end
end
