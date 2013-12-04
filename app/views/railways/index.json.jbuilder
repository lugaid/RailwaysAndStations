json.array!(@railways) do |railway|
  json.extract! railway, :name, :abreviation, :description
  json.url railway_url(railway, format: :json)
end
