class HolidaysController < ApplicationController
  before_action :admin_user, except: [:index]
  before_action :set_holiday, except: [:new, :index]

  def new
    @holiday = Holiday.new
  end

  def create
    if @holiday.save
      flash[:info] = "Holiday added successfully."
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
    if @holiday.update_attributes(holiday_params)
      flash[:success] = "Holiday updated"
      redirect_to holidays_url
    else
      render 'edit'
    end
  end

  def destroy
    if @holiday.destroy
      flash[:success] = "Holiday deleted"
      redirect_to holidays_url
    end
  end

  private

    def set_holiday
      @holiday = params[:id].present? ? Holiday.find(params[:id]) : Holiday.new(holiday_params)
    end

    def holiday_params
      params.require(:holiday).permit(:date, :occasion)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
