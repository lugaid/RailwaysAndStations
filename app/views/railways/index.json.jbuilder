json.array!(@railways) do |railway|
  json.extract! railway, :name, :abbreviation, :description
  json.url railway_url(railway, format: :json)
end
