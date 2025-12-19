class EnqueueOrder
  def initialize(order_repository)
    @repo = order_repository
  end

  def execute(pedido_id:, items: [])
    id = SecureRandom.uuid
    order = Order.new(id: id, pedido_id: pedido_id, items: items)
    @repo.enqueue(order)
    order
  end
end
