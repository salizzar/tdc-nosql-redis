require 'redis'

class RedisDriver
  def initialize(redis)
    @redis = redis
    @scripts = {}
  end

  def driver
    @redis
  end

  def run_script(script_name, data)
    # lazy load script
    unless @scripts.include?(script_name)
      content = File.read("./lib/scripts/#{script_name}.lua")

      @scripts[script_name] = @redis.script(:load, content)
    end

    script_sha = @scripts[script_name]

    @redis.evalsha(script_sha, keys: data)
  rescue Redis::CommandError => e
    raise unless no_script?(e)

    @redis.eval(script_sha, keys: data)
  end

  private

  def no_script?(e)
    e.message.start_with?('NOSCRIPT')
  end

  def sha(script)
    OpenSSL::Digest::SHA1.hexdigest(script)
  end
end

