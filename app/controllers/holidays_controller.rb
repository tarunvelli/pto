class HolidaysController < ApplicationController
  before_action :admin_user, except: [:index] 
  before_action :set_holiday, except: [:create,:index]


  def new
  end

  def create
    @holiday = Holiday.new(holiday_params)
    if @holiday.save
      flash[:info] = "Holiday added successfully."
    else
      render 'new'
    end
  end

  def index
    @holidays = Holiday.all
    @users = User.all
  end

  def edit
  end

  def update
    if @holiday.update_attributes(holiday_params)
      flash[:success] = "Holiday updated"
    else
      render 'edit'
    end
  end

  def destroy
    @holiday.destroy
    flash[:success] = "Holiday deleted"
  end

  private

    def set_holiday
      @holiday = params[:id].present? ? Holiday.find(params[:id]) : Holiday.new
    end

    def holiday_params
      params.require(:holiday).permit(:date, :occasion)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
