json.array!(@items) do |item|
  json.extract! item, :id, :name, :description, :price, :company, :link
  json.url item_url(item, format: :json)
end
