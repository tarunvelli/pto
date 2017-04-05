json.array!(@leaves) do |leave|
  json.start leave.leave_start_from
  json.end leave.leave_end_at + 1
end