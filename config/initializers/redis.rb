if Rails.env.development?
  $redis = Redis::Namespace.new("simplr", :redis => Redis.new)
end
