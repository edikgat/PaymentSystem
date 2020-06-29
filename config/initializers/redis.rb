require "redis"

current_redis_config = YMLConfigReader.fetch(Rails.root.join('config/redis.yml'), Rails.env)

$redis = Redis::Namespace.new(Rails.env, redis: Redis.new(current_redis_config))
