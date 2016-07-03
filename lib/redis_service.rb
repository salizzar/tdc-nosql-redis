require_relative 'redis_driver'

class RedisService
  def initialize(redis)
    @redis = redis
  end

  def log=(log)
    @log = log
  end

  def batch_without_lua(limit)
    result = 0

    @log.info(" [safe] running with limit #{limit}")

    limit.times do
      result = @redis.driver.incr :batch_total_non_lua

      @redis.driver.sadd :batch_members_non_lua, result
    end

    { total: result, items: @redis.driver.smembers(:batch_members_non_lua) }
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
      limit.times do
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

