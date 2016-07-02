require_relative 'redis_driver'

class RedisService
  def initialize(redis, log)
    @redis = redis
    @log = log

    @redis.driver.flushall
  end

  def lock_unsafe(limit)
    @log.info("![lock] running with limit #{limit}")

    (1..limit).times do
      @redis.driver.incr :lock_unsafe_total
    end

    { total: @redis.driver.get(:lock_unsafe_total) }
  end

  def lock_safe(limit)
    @log.info(" [lock] running with limit #{limit}")

    @redis.driver.lock("safe", 600, 1000) do
      (1..limit).times do
        @redis.driver.incr :lock_safe_total
      end
    end

    { total: @redis.driver.get(:lock_safe_total) }
  end

  def batch_with_lua(limit)
    @log.info(" [lua] batch with limit #{limit}")

    result = @redis.run_script(:batch, [limit.to_s])

    { total: result[0], items: result[1] }
  end

  def multi_without_lua(limit)
    result = 0

    @log.info("![lua] multi with limit #{limit}")

    @redis.driver.multi do
      (1..limit).to_a.each do |i|
        @redis.driver.incr :multi_total_non_lua

        @redis.driver.sadd :multi_members_non_lua, result
      end
    end

    { total: @redis.driver.get(:multi_total_non_lua), items: @redis.driver.smembers(:multi_members_non_lua) }
  end

  def multi_with_lua(limit)
    @log.info(" [lua] multi with limit #{limit}")

    result = @redis.run_script(:multi, [limit.to_s])

    { total: result[0], items: result[1] }
  end
end

