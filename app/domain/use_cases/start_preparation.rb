class StartPreparation
  def initialize(order_repository)
    @repo = order_repository
  end

  def execute(order_id:)
    order = @repo.find_by_id(order_id)
    raise 'Order not found' unless order
    order.status = 'EM_PREPARACAO'
    @repo.update(order)
    order
  end
end
