class ProductionWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 3

  def perform(order_id)
    repo = RedisOrderRepository.new
    order = repo.find_by_id(order_id)
    unless order
      puts "order nao encontrada"
      return
    end

    order.start_preparation!
    repo.update(order)
    puts "⌛ Preparando pedido #{order_id}"
    sleep 5 # simula preparo

    order.mark_ready!
    repo.update(order)
    puts "✅ Pedido  #{order_id}, pronto!"
  end
end
