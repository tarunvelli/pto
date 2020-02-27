# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :ensure_signed_in
  before_action :set_user, except: %i[index download_users_details]
  before_action :check_user, except: %i[index download_users_details]
  before_action :check_admin, only: %i[download_users_details]

  def update
    if @user.update(user_params)
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def index
    @financial_year = params[:financial_year] || OOOConfig.current_financial_year
    @financial_years = OOOConfig.all.order('financial_year DESC').pluck('financial_year')
    @users = User.where('joining_date <= ?', FinancialYear.new(@financial_year).end_date)
  end

  def download_users_details
    rows = []
    rows << [
      'Name', 'Email', 'Joining Date', 'Employee Id', 'DOB', 'Contact Number', 'Personal Email',
      'Blood Group', 'Emergency Contact Number', 'Mailing Address', 'Fathers Name',
      'Aadhar Number', 'PAN Number', 'Passport Number'
    ]
    User.where(active: true).each do |user|
      rows << user.details_array
    end
    csv_string = CSV.generate do |csv|
      rows.each do |row|
        csv << row
      end
    end

    file_name = "Employees_data_#{Time.current.strftime('%m-%d-%y_%H-%M-%S')}.csv"
    send_data(csv_string,
              disposition: 'attachment', filename: file_name,
              type: 'text/csv; charset=utf-8; header=present')
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def check_user
    redirect_to current_user unless current_user == @user || current_user.admin?
  end

  def check_admin
    redirect_to current_user unless current_user.admin?
  end

  def user_params
    params.require(:user).permit(
      :name, :joining_date, :employee_id, :dob, :leaving_date, :fathers_name,
      :adhaar_number, :pan_number, :blood_group, :emergency_contact_number,
      :mailing_address, :personal_email, :contact_number, :passport_number
    )
  end
end
