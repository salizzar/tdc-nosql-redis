local result = 0
local limit = tonumber(KEYS[1])

for i = 1, limit, 1 do
  result = redis.call('incr', 'batch_total_lua')

  redis.call('sadd', 'batch_members_lua', result)
end

return { result, redis.call('smembers', 'batch_members_lua') }

