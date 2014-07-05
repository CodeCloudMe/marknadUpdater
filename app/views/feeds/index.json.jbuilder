json.array!(@feeds) do |feed|
  json.extract! feed, :id, :title
  json.url feed_url(feed, format: :json)
end
