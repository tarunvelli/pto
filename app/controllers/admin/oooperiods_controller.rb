class Admin::OooperiodsController < ApplicationController
  before_action :admin_user
  before_action :load_user
  before_action :set_leave, except: [:create]

  def create
    @leave = current_user.leaves.build(leave_params)
    if @leave.save
      flash[:success] = 'OOO period form Submitted!'
      redirect_to admin_user_url(@user)
    else
      render 'new'
    end
  end

  def update
    byebug
    if @leave.update_attributes(leave_params)
      flash[:success] = 'OOO period updated Successfully'
      redirect_to admin_user_url(@user)
    else
      render 'edit'
    end
  end

  def destroy
    return unless @leave.destroy
    flash[:success] = 'OOO Cancelled'
    redirect_to leaves_url
  end


  private

  def load_user
    @user = User.find(params[:user_id])
  end

  def set_leave
    @leave = params[:id].present? ? Leave.find(params[:id]) : Leave.new
  end

  def leave_params
    params.require(:leave).permit(
      :start_date, :end_date
    )
  end

end
