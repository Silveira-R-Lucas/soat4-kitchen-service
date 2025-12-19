class FinalizeOrder
  def initialize(order_repository)
    @repo = order_repository
  end

  def execute(order_id:)
    order = @repo.find_by_id(order_id)
    raise "Order not found" unless order
    order.status = "FINALIZADO"
    @repo.update(order)
    order
  end
end
