class RabbitmqConsumer
  require "json"

  def initialize(exchange_name, queue_name, handlers = {})
    @channel = RabbitmqConnection.channel
    @exchange = @channel.fanout(exchange_name, durable: true)
    @queue = @channel.queue(queue_name, durable: true)
    @queue.bind(@exchange)
    @handlers = handlers
  end

  def start_listening
    Rails.logger.info("🎧 Listening to #{@queue.name}")
    @queue.subscribe(block: true, manual_ack: true) do |delivery_info, properties, payload|
      handle_message(payload)
      @channel.ack(delivery_info.delivery_tag)
    end
  rescue Interrupt
    @channel.close
    RabbitmqConnection.instance.close
  end

  private

  def handle_message(payload)
    data = JSON.parse(payload)
    event = data["event"]
    payload_data = data["payload"]
    handler = @handlers[event]
    repo = RedisOrderRepository.new
    puts "payload_data: #{payload_data}"
    puts "payload: #{payload}"
    if event == "PagamentoAprovado"
      puts "⌛ Iniciando pedido #{payload_data["pedido_id"]}"
      order = EnqueueOrder.new(repo).execute(pedido_id: payload_data["pedido_id"], items: payload_data["items"] || [])
      puts "pedido id #{order.id}"
      ProductionWorker.perform_async(order.id)
    end
  rescue => e
    Rails.logger.error("❌ Error handling message: #{e.message}")
  end
end
