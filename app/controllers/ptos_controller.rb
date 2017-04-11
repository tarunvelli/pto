class PtosController < ApplicationController
  before_action :admin_user
  before_action :set_pto

  def edit
  end


  def update
    @pto.no_of_pto = params[:no_of_pto]
    if @pto.save
      flash[:success] = "pto's updated"
      redirect_to edit_ptos_path
    else
      render 'edit'
    end
  end

  private

  def set_pto
    @pto = Pto.first
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end

