json.array!(@statistics) do |statistic|
  json.extract! statistic, :id, :user_id
  json.url statistic_url(statistic, format: :json)
end
