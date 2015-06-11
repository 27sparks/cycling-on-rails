json.values params[:values]
json.array! @results do |result|
  json.extract!(result, :name, :value)
  json.unit params[:unit]
end
