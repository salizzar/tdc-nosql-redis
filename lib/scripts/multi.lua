local limit = tonumber(KEYS[1])

redis.call('multi')

for i = 1, limit, 1 do
  redis.call('incr', 'multi_total_lua')

  redis.call('sadd', 'multi_members_lua', result)
end

redis.call('exec')

return { redis.call('get', 'multi_total_lua'), redis.call('smembers', 'multi_members_lua') }

