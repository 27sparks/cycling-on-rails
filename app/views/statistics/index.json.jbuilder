json.array! @results do |result|
  json.array!(result, :name, :value)
end
