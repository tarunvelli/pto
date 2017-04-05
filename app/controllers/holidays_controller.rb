class HolidaysController < ApplicationController
  before_action :admin_user, except: [:index] 


  def new
    @holiday = Holiday.new
  end

  def create
    @holiday = Holiday.new(holiday_params)
    if @holiday.save
      flash[:info] = "Holiday added successfully."
      redirect_to holidays_path
    else
      render 'new'
    end
  end

  def index
    @holidays = Holiday.all
    @users = User.all
  end

  def edit
    @holiday = Holiday.find(params[:id])
  end

  def update
    @holiday = Holiday.find(params[:id])
    if @holiday.update_attributes(holiday_params)
      flash[:success] = "Holiday updated"
      redirect_to holidays_path
    else
      render 'edit'
    end
  end

  def destroy
    Holiday.find(params[:id]).destroy
    flash[:success] = "Holiday deleted"
    redirect_to holidays_path
  end

  private

    def holiday_params
      params.require(:holiday).permit(:date, :occasion)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
