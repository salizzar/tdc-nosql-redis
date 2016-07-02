require 'cuba'
require 'json'

require_relative 'lib/redis_service'

Cuba.define do
  log = env['rack.logger']

  conn = Redis.new(host: :redis)
  redis = RedisDriver.new(conn)
  service = RedisService.new(redis, log)

  on get do
    on root do
      res.write "Hello stranger :)\n"
    end

    on "lock/without", param("limit") do |limit|
      log.info("Tryng to run lock unsafe with limit #{limit}")

      result = service.lock_unsafe(limit.to_i)

      res.status = result[:total].to_i > limit.to_i ? 400 : 200
      res.write("#{JSON.generate(result)}\n")
    end

    on "lock/with", param("limit") do |limit|
      log.info("Tryng to run lock safe with limit #{limit}")

      result = service.lock_safe(limit.to_i)

      res.status = result[:total].to_i > limit.to_i ? 400 : 200
      res.write("#{JSON.generate(result)}\n")
    end

    on "batch/lua/without", param("limit") do |limit|
      log.info("Tryng to run batch without lua script with limit #{limit}")

      result = service.batch_without_lua(limit.to_i)

      res.status = 200
      res.write("#{JSON.generate(result)}\n")
    end

    on "batch/lua/with", param("limit") do |limit|
      log.info("Tryng to run batch with lua script with limit #{limit}")

      result = service.batch_with_lua(limit.to_s)

      res.status = 200
      res.write("#{JSON.generate(result)}\n")
    end

    on "multi/lua/without", param("limit") do |limit|
      log.info("Tryng to run multi without lua script with limit #{limit}")

      result = service.multi_without_lua(limit.to_i)

      res.status = 200
      res.write("#{JSON.generate(result)}\n")
    end

    on "multi/lua/with", param("limit") do |limit|
      log.info("Tryng to run multi with lua script with limit #{limit}")

      result = service.multi_with_lua(limit.to_s)

      res.status = 200
      res.write("#{JSON.generate(result)}\n")
    end
  end
end

