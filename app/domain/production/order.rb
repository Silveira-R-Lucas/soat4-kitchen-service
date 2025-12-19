class Order
  attr_accessor :id, :pedido_id, :items, :status, :created_at, :updated_at

  def initialize(id:, pedido_id:, items:, status: "RECEBIDO", created_at: Time.now, updated_at: Time.now)
    @id = id
    @pedido_id = pedido_id
    @items = items
    @status = status
    @created_at = created_at
    @updated_at = updated_at
  end

  def to_h
    {
      id: id,
      pedido_id: pedido_id,
      items: items,
      status: status,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  def start_preparation!
    @status = "EM_PREPARACAO"
    @updated_at = Time.now
  end

  def mark_ready!
    @status = "PRONTO"
    @updated_at = Time.now
  end

  def finalize!
    @status = "FINALIZADO"
    @updated_at = Time.now
  end
end
