# frozen_string_literal: true

class StartKitchenConsumer
  def self.run
    RabbitmqConsumer.new("pagamento.events", "kitchen.pagamento-aprovado").start_listening
  end
end