# frozen_string_literal: true

class LeavesController < ApplicationController
  before_action :ensure_signed_in
  before_action :set_leave, except: [:create]

  def index
    @total_leaves = current_user.leaves.order('end_date DESC')
    @a = [];
    @total_leaves.each do |leave|
      lea = {}
      lea[:startDate] = leave.start_date
      lea[:endDate] = leave.end_date
      @a.push(lea)
    end
    @a = @a.to_json
    @editable_leaves = current_user.leaves.where("end_date > ?",Date.current)
  end

  def create
    @leave = current_user.leaves.build(leave_params)
    if @leave.save
      flash[:success] = 'Leave form Submitted!'
      redirect_to leaves_url
    else
      render 'new'
    end
  end

  def update
    if @leave.update_attributes(leave_params)
      flash[:success] = 'Leave updated Successfully'
      redirect_to leaves_url
    else
      render 'edit'
    end
  end

  def destroy
    return unless @leave.destroy
    flash[:success] = 'Leave Cancelled'
    redirect_to leaves_url
  end

  def number_of_days
    @days = Leave.business_days_between(
      params[:start_date].to_date,
      params[:end_date].to_date
    )
    render json: @days
  end

  private

  def set_leave
    @leave = params[:id].present? ? Leave.find(params[:id]) : Leave.new
  end

  def leave_params
    params.require(:leave).permit(
      :start_date, :end_date
    )
  end
end
