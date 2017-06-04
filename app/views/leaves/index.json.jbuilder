# frozen_string_literal: true

json.array!(@leaves) do |leave|
  json.start leave.start_date
  json.end leave.end_date + 1
end
