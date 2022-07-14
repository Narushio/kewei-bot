REDIS = ConnectionPool::Wrapper.new(size: 5, timeout: 3) { Redis.new(url: Settings.redisUrl) }
