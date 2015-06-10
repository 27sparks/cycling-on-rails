json.distances @distances do |distance|
  json.extract!(distance, :km, :month)
end
