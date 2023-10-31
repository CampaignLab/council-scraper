$redis = ConnectionPool::Wrapper.new(size: 25, timeout: 3) { Redis.new(url: ENV['REDIS_URL']) }
