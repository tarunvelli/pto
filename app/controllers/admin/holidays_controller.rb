# frozen_string_literal: true

class Admin::HolidaysController < ApplicationController
  before_action :admin_user
  before_action :set_holiday, except: [:create]
  before_action :load_ooo_config

  def create
    @holiday = @ooo_config.holidays.build(holiday_params)
    if @holiday.save
      flash[:success] = 'Holiday added successfully.'
      redirect_to controller: 'admin/users', action: 'index', financial_year: @ooo_config.financial_year
    else
      render 'new'
    end
  end

  def update
    if @holiday.update(holiday_params)
      flash[:success] = 'Holiday updated'
      redirect_to controller: 'admin/users', action: 'index', financial_year: @ooo_config.financial_year
    else
      render 'edit'
    end
  end

  def destroy
    return unless @holiday.destroy

    flash[:success] = 'Holiday deleted.'
    redirect_to controller: 'admin/users', action: 'index', financial_year: @ooo_config.financial_year
  end

  private

  def load_ooo_config
    @ooo_config = OOOConfig.find(params[:oooconfig_id])
  end

  def set_holiday
    @holiday = params[:id].present? ? Holiday.find(params[:id]) : Holiday.new
  end

  def holiday_params
    params.require(:holiday).permit(:date, :occasion)
  end
end
