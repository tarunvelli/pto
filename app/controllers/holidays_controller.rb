# frozen_string_literal: true

class HolidaysController < ApplicationController
  before_action :admin_user, except: [:index]
  before_action :set_holiday, except: [:index]

  def create
    if @holiday.save
      flash[:info] = 'Holiday added successfully.'
      redirect_to holidays_url
    else
      render 'new'
    end
  end

  def index
    @holidays = Holiday.all
    @users = User.all
  end

  def update
    if @holiday.update_attributes holiday_params
      flash[:success] = 'Holiday updated'
      redirect_to holidays_url
    else
      render 'edit'
    end
  end

  def destroy
    return unless @holiday.destroy
    flash[:success] = 'Holiday deleted.'
    redirect_to holidays_url
  end

  private

  def set_holiday
    @holiday = Holiday.where(id: params[:id]).first_or_initialize(
      holiday_params
    )
  end

  def holiday_params
    return if params[:holiday].blank?
    params.require(:holiday).permit(:date, :occasion)
  end
end
