json.array!(@messages) do |message|
  json.extract! message, :id, :user_id, :receiver_id, :group_id, :body, :image
  json.url message_url(message, format: :json)
end
