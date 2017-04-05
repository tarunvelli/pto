class LeavesController < ApplicationController
  before_action :logged_in_user

	def new
	  @leave = Leave.new
    end

    def index
    	@leave = Leave.new
    	@leaves = current_user.leaves.order('created_at DESC')
    end

	def create
	    @leave = current_user.leaves.build(leave_params)
	    @leave.number_of_days = days_count
	    if @leave.save
	      flash[:success] = "Leave form Submitted!"
	      current_user.remaining_leaves =  current_user.remaining_leaves.to_i - @leave.number_of_days.to_i
	      current_user.save
        Slacked.post " #{current_user.name} will be on leave from #{params[:leave][:leave_start_from]} to #{params[:leave][:leave_end_at]} "
	      redirect_to leaves_url
	    else
	      render 'new'
	    end
    end

    def edit
     @leave = Leave.find(params[:id])
    end

    def update
      @leave = Leave.find(params[:id])
      no_of_days = @leave.number_of_days
      @leave.number_of_days = days_count
      if @leave.update_attributes(leave_params)
        flash[:success] = "Leave updated Successfully"
        current_user.remaining_leaves =  current_user.remaining_leaves.to_i - no_of_days + @leave.number_of_days.to_i 
        current_user.save
        redirect_to leaves_url
      else
        render 'edit'
     end
    end

    def destroy
      @leave = Leave.find(params[:id])
    	current_user.remaining_leaves =  current_user.remaining_leaves.to_i + @leave.number_of_days.to_i
    	if @leave.destroy
    		flash[:success] = "Leave Cancelled"
    		current_user.save
        redirect_to leaves_url
    	end	
    end

    private

    def leave_params
      params.require(:leave).permit(:leave_start_from, :leave_end_at, :number_of_half_days, 
      				:reason, :number_of_days)
    end

    def days_count
    	(business_days_between(params[:leave][:leave_start_from].to_date,
	    	params[:leave][:leave_end_at].to_date)) - params[:leave][:number_of_half_days].to_i/2 
    end

	def business_days_between(date1, date2)
	  business_days = 0
	  date = date2
	  while date >= date1
		   business_days = business_days + 1 unless date.saturday? or date.sunday?
		   date = date - 1.day
	  end
	  business_days
	end
end
