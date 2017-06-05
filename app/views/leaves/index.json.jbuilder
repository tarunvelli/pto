# frozen_string_literal: true

json.array!(@total_leaves) do |leave|
  json.startDate Date.new(leave.start_date)
  json.endDate Date.new(leave.end_date)
end
