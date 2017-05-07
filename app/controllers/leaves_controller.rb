class LeavesController < ApplicationController
  before_action :logged_in_user
  before_action :set_leave, except: [:create]

  def index
    @leaves = current_user.leaves.order('created_at DESC')
  end

  def create
    @leave = current_user.leaves.build(leave_params)
    if @leave.save
      flash[:success] = "Leave form Submitted!"
      redirect_to leaves_url
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @leave.update_attributes(leave_params)
      flash[:success] = "Leave updated Successfully"
      redirect_to leaves_url
    else
      render 'edit'
    end
  end

  def destroy
    if @leave.destroy
      flash[:success] = "Leave Cancelled"
      redirect_to leaves_url
    end
  end

  def number_of_days
    @days = Leave.business_days_between(
      params[:start_date].to_date,
      params[:end_date].to_date
    )

    render json:@days
  end

  private

  def set_leave
    @leave = params[:id].present? ? Leave.find(params[:id]) : Leave.new
  end

  def leave_params
    params.require(:leave).permit(
      :leave_start_from, :leave_end_at, :reason
    )
  end

end
