# frozen_string_literal: true

module UserConcerns
  extend ActiveSupport::Concern

  def details_array
    [
      name, email, joining_date, employee_id, self.DOB, contact_number, personal_email,
      blood_group, emergency_contact_number, mailing_address, fathers_name,
      adhaar_number, self.PAN_number, passport_number
    ]
  end

  def all_details?
    required_details = details_array
    required_details.delete_at(3)
    required_details.all?(&:present?)
  end
end
