class RedisOrderRepository
  require "json"
  require "time"
  require "securerandom"
  QUEUE_KEY = "default:queue".freeze
  ORDER_KEY_PREFIX = "default:order:".freeze
  INPROGRESS_SET = "default:in_progress".freeze

  def initialize(redis = REDIS)
    @redis = redis
  end

  def enqueue(domain_order)
    id = domain_order.id || SecureRandom.uuid
    order_hash = domain_order.to_h.merge("id" => id, "created_at" => domain_order.created_at.to_s, "updated_at" => domain_order.updated_at.to_s)
    @redis.hmset(order_key(id), *hash_to_flat(order_hash))
    @redis.rpush(QUEUE_KEY, id)
    id
  end

  def pop_next
    id = @redis.lpop(QUEUE_KEY)
    return nil unless id
    data = @redis.hgetall(order_key(id))
    return nil if data.nil? || data.empty?
    mark_in_progress(id)
    build_domain_order(data)
  end

  def find_by_id(id)
    data = @redis.hgetall(order_key(id))
    return nil if data.nil? || data.empty?
    build_domain_order(data)
  end

  def update(domain_order)
    id = domain_order.id
    @redis.hmset(order_key(id), *hash_to_flat(domain_order.to_h))
    if domain_order.status == "EM_PREPARACAO"
      mark_in_progress(id)
    elsif domain_order.status == "FINALIZADO"
      @redis.srem(INPROGRESS_SET, id)
    end
    true
  end

  def list_in_progress
    ids = @redis.smembers(INPROGRESS_SET)
    ids.map { |id| find_by_id(id) }
  end

  private

  def order_key(id)
    "#{ORDER_KEY_PREFIX}#{id}"
  end

  def hash_to_flat(h)
    h.flat_map { |k, v| [ k, v.is_a?(Array) || v.is_a?(Hash) ? v.to_json : v.to_s ] }
  end

  def build_domain_order(data)
    items = data["items"] ? JSON.parse(data["items"]) : []
    Order.new(
      id: data["id"],
      pedido_id: data["pedido_id"],
      items: items,
      status: data["status"],
      created_at: Time.parse(data["created_at"]),
      updated_at: Time.parse(data["updated_at"])
    )
  end

  def mark_in_progress(id)
    @redis.sadd(INPROGRESS_SET, id)
  end
end
