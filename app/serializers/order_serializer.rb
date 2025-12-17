class OrderSerializer
  def initialize(order); @order = order; end
  def as_json(*)
    @order.to_h
  end
end
